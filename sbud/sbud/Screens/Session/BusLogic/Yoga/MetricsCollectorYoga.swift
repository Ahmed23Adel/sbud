//
//  MetricsCollectorYoga.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//


import Foundation
import OSLog
import FirebaseFirestore

@Observable
class MetricsCollectorYoga: MetricsCollector, MetricsCollectorTimeable {

    let startDateTime = Date()

    // MARK: - Public state
    var elapsedSeconds: Double = 0
    var isTracking = false

    // MARK: - Private
    private var startDate: Date?
    private var timer: Timer?
    let isCreator: Bool
    private let numSessions: Int
    private let logger = Logger(subsystem: "sbud", category: "MetricsCollectorYoga")

    init(isCreator: Bool, numSessions: Int) {
        self.isCreator = isCreator
        self.numSessions = numSessions
    }

    // MARK: - Control

    /// eventId unused for time-only collectors — startDate is restored
    /// from LocalOnGoingSession in the view model, not from a checkpoint.
    func startSession(eventId: String) {
        logger.info("Starting Tennis session")
        reset()
        startDate = Date()
        isTracking = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            self.elapsedSeconds = Date().timeIntervalSince(start)
        }
    }

    /// Called by the view model after reading LocalOnGoingSession.
    /// Rewinds elapsedSeconds so the timer view shows the correct
    /// total time including time before a crash/relaunch.
    func restoreStartDate(_ date: Date) {
        startDate = date
    }

    func endSession(event: EventFullDetails) async throws {
        timer?.invalidate()
        timer = nil
        isTracking = false

        let userId = ProfileManager.shared.getLocalProfile()!.id

        if isCreator {
            try await creatorEndsSession(eventId: event.id, userId: userId)
        } else {
            try await participantEndsSession(eventId: event.id, userId: userId)
        }
    }

    // MARK: - Creator end

    private func creatorEndsSession(eventId: String, userId: String) async throws {
        let endDateTime = Date()

        let metrics = MetricsCollectedGym(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            metricsCreatorType: .creator,
            numSession: numSessions
        )

        try await metrics.upload(eventId: eventId, userId: userId)

        let db = Firestore.firestore()
        try await db.collection("Events").document(eventId).updateData([
            "finalStartDateTime": startDate as Any,
            "finalEndDateTime": endDateTime,
            "status": UsersEventStatus.completed.rawValue,
            "numSessions": numSessions + 1
        ])
    }

    // MARK: - Participant end

    private func participantEndsSession(eventId: String, userId: String) async throws {
        guard let data = try await db.collection("Events").document(eventId)
            .getDocument().data() else { throw MetricsError.eventNotFound }

        guard let finalEndDateTime = try await MetricsCollectorUtils
            .readFinalEndDateTime(eventId: eventId) else {
            logger.info("Yoga participant ended before creator — storing data only")
            try await MetricsCollectedGym(
                startDateTime: startDateTime,
                endDateTime: Date(),
                metricsCreatorType: .normalParticipant,
                endedBeforeCreator: true,
                numSession: numSessions
            ).upload(eventId: eventId, userId: userId)
            return
        }

        try await MetricsCollectedGym(
            startDateTime: startDateTime,
            endDateTime: finalEndDateTime,
            metricsCreatorType: .normalParticipant,
            endedBeforeCreator: false,
            numSession: numSessions
        ).upload(eventId: eventId, userId: userId)

        logger.info("Yoga participant metrics uploaded")
    }

    // MARK: - Helpers

    private var db: Firestore { Firestore.firestore() }

    private func reset() {
        elapsedSeconds = 0
        startDate = nil
    }
}
