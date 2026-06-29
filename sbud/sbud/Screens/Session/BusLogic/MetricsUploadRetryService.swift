//
//  MetricsUploadRetryService.swift
//  sbud
//
//  Created by ahmed on 31/05/2026.
//

import Foundation
import SwiftData
import UIKit
import OSLog

/// Retries pending metrics uploads that were deferred at session end.
///
/// A drain is triggered on three occasions:
///   1. App launch / foreground  (`start()` + `UIApplication.willEnterForegroundNotification`)
///   2. Network restores         (via `NetworkMonitoring.onChange`)
///   3. Every 10 minutes while the app is active
///
/// Two conditions must be true before a **participant** entry uploads:
///   - Network is reachable
///   - `finalEndDateTime` exists on the Event document (creator has ended)
/// After 24 hours with no `finalEndDateTime`, the entry uploads anyway with a fallback end time.
///
/// **Creator** entries only require network — they upload as soon as connectivity returns.
@MainActor
final class MetricsUploadRetryService {

    // MARK: - Singleton

    static let shared = MetricsUploadRetryService()

    // MARK: - Configuration

    private let retryInterval: TimeInterval = 600        // 10 minutes
    private let fallbackTimeout: TimeInterval = 86_400   // 24 hours

    // MARK: - Dependencies

    private let networkMonitor: NetworkMonitoring
    private let logger = Logger(subsystem: "sbud", category: "MetricsUploadRetryService")

    // MARK: - State

    private var retryTimer: Timer?

    // MARK: - Init (injectable for testing)

    init(networkMonitor: NetworkMonitoring = NetworkMonitor.shared) {
        self.networkMonitor = networkMonitor
    }

    // MARK: - Lifecycle

    func start() {
        logger.info("MetricsUploadRetryService starting")

        // 1. Network restore trigger
        networkMonitor.startMonitoring { [weak self] isConnected in
            guard isConnected else { return }
            Task { @MainActor [weak self] in
                self?.logger.info("Network restored — triggering drain")
                await self?.attemptDrain()
            }
        }

        // 2. App foreground trigger
        // This listens for when the app comes back from the background (e.g. user switches back from another app).
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification, // fired by iOS just before the app becomes active again
            object: nil,
            queue: .main //  the callback runs on the main thread
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.logger.info("App foregrounded — triggering drain")
                await self?.attemptDrain()
            }
        }

        // 3. Periodic timer trigger
        retryTimer = Timer.scheduledTimer(
            withTimeInterval: retryInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.logger.info("Retry timer fired — triggering drain")
                await self?.attemptDrain()
            }
        }

        // 4. Immediate attempt on launch (covers entries from previous app sessions)
        Task { @MainActor [weak self] in
            await self?.attemptDrain()
        }
    }

    // MARK: - Drain

    /// Processes all pending entries. Stops early if a network error is encountered.
    func attemptDrain() async {
        guard networkMonitor.isConnected else {
            logger.info("Drain skipped — no network")
            return
        }

        let context = AppModelContainer.shared.mainContext
        let entries: [PendingMetricsUpload]

        do {
            entries = try context.fetch(FetchDescriptor<PendingMetricsUpload>())
        } catch {
            logger.error("Failed to fetch pending uploads: \(error)")
            return
        }

        guard !entries.isEmpty else {
            logger.info("Drain: no pending entries")
            return
        }

        logger.info("Drain started — \(entries.count) pending entry(s)")

        for entry in entries {
            let shouldContinue = await processEntry(entry, context: context)
            if !shouldContinue {
                logger.warning("Drain stopped early — network failure mid-drain")
                break
            }
        }

        logger.info("Drain finished")
    }

    // MARK: - Entry dispatch

    /// Returns `false` if the drain should stop (network down), `true` to continue.
    private func processEntry(_ entry: PendingMetricsUpload, context: ModelContext) async -> Bool {
        guard entry.activityType == .running else {
            // Other sports will be handled in future checkpoints
            logger.info("Skipping \(entry.activityType.rawValue) entry for event \(entry.eventId) — not yet handled")
            return true
        }

        guard let snapshot = try? JSONDecoder().decode(RunSessionSnapshot.self, from: entry.snapshotData) else {
            logger.error("Corrupt snapshot for event \(entry.eventId) — removing entry")
            deleteEntry(entry, context: context)
            return true
        }

        if entry.isCreator {
            return await processCreatorEntry(entry, snapshot: snapshot, context: context)
        } else {
            return await processParticipantEntry(entry, snapshot: snapshot, context: context)
        }
    }

    // MARK: - Creator entry

    private func processCreatorEntry(
        _ entry: PendingMetricsUpload,
        snapshot: RunSessionSnapshot,
        context: ModelContext
    ) async -> Bool {
        guard
            let updateData = entry.creatorEventUpdateData,
            let eventUpdate = try? JSONDecoder().decode(CreatorEventUpdate.self, from: updateData)
        else {
            logger.error("Missing creator event update for event \(entry.eventId) — removing corrupt entry")
            deleteEntry(entry, context: context)
            return true
        }

        do {
            logger.info("Retrying creator upload for event \(entry.eventId)")
            try await RunMetricsUploader.uploadCreator(
                snapshot: snapshot,
                eventUpdate: eventUpdate,
                userId: entry.userId
            )
            deleteEntry(entry, context: context)
            logger.info("Creator upload succeeded for event \(entry.eventId)")
            return true
        } catch {
            logger.warning("Creator upload failed for event \(entry.eventId) — will retry later: \(error)")
            return false
        }
    }

    // MARK: - Participant entry

    private func processParticipantEntry(
        _ entry: PendingMetricsUpload,
        snapshot: RunSessionSnapshot,
        context: ModelContext
    ) async -> Bool {
        let finalEndDateTime: Date?

        do {
            finalEndDateTime = try await MetricsCollectorUtils.readFinalEndDateTime(eventId: entry.eventId)
            logger.info("finalEndDateTime for event \(entry.eventId): \(String(describing: finalEndDateTime))")
        } catch MetricsError.eventNotFound {
            logger.error("Event \(entry.eventId) no longer exists — removing stale entry")
            deleteEntry(entry, context: context)
            return true
        } catch {
            // Any other error is a network failure — stop the entire drain
            logger.warning("Network error reading finalEndDateTime for \(entry.eventId) — stopping drain: \(error)")
            return false
        }

        if let finalEndDateTime {
            return await uploadParticipant(
                entry: entry,
                snapshot: snapshot,
                finalEndDateTime: finalEndDateTime,
                context: context
            )
        }

        // Creator hasn't ended yet — check 24h fallback
        let elapsed = Date().timeIntervalSince(entry.enqueuedAt)
        guard elapsed >= fallbackTimeout else {
            logger.info("Creator hasn't ended event \(entry.eventId) yet (\(Int(elapsed / 3600))h elapsed) — will retry later")
            return true
        }

        logger.warning("24h timeout reached for event \(entry.eventId) — uploading with fallback")
        return await uploadParticipantFallback(entry: entry, snapshot: snapshot, context: context)
    }

    // MARK: - Upload helpers

    private func uploadParticipant(
        entry: PendingMetricsUpload,
        snapshot: RunSessionSnapshot,
        finalEndDateTime: Date,
        context: ModelContext
    ) async -> Bool {
        do {
            try await RunMetricsUploader.uploadParticipant(
                snapshot: snapshot,
                finalEndDateTime: finalEndDateTime,
                userId: entry.userId,
                numSession: entry.numSession
            )
            deleteEntry(entry, context: context)
            logger.info("Participant upload succeeded for event \(entry.eventId)")
            return true
        } catch {
            logger.warning("Participant upload failed for event \(entry.eventId) — will retry later: \(error)")
            return false
        }
    }

    private func uploadParticipantFallback(
        entry: PendingMetricsUpload,
        snapshot: RunSessionSnapshot,
        context: ModelContext
    ) async -> Bool {
        do {
            try await RunMetricsUploader.uploadParticipantFallback(
                snapshot: snapshot,
                userId: entry.userId,
                numSession: entry.numSession
            )
            deleteEntry(entry, context: context)
            logger.info("Participant fallback upload succeeded for event \(entry.eventId)")
            return true
        } catch {
            logger.warning("Participant fallback upload failed for event \(entry.eventId) — will retry later: \(error)")
            return false
        }
    }

    // MARK: - SwiftData

    private func deleteEntry(_ entry: PendingMetricsUpload, context: ModelContext) {
        context.delete(entry)
        try? context.save()
    }
}
