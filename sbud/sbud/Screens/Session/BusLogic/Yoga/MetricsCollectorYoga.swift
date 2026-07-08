//
//  MetricsCollectorYoga.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import Foundation
import HealthKit
import OSLog
import FirebaseFirestore

@Observable
class MetricsCollectorYoga: MetricsCollector, MetricsCollectorTimeable {

    let startDateTime = Date()

    // MARK: - Public state
    var elapsedSeconds: Double = 0
    var isTracking = false

    // MARK: - Private
    private let healthKit: HealthKitServing
    private let userIdProvider: () -> String?
    private var startDate: Date?
    private var timer: Timer?
    let isCreator: Bool
    private let numSessions: Int
    private let logger = Logger(subsystem: "sbud", category: "MetricsCollectorYoga")

    init(
        isCreator: Bool,
        numSessions: Int,
        healthKit: HealthKitServing = HealthKitService.shared,
        userIdProvider: @escaping () -> String? = { ProfileManager.shared.getLocalProfile()?.id }
    ) {
        self.isCreator = isCreator
        self.numSessions = numSessions
        self.healthKit = healthKit
        self.userIdProvider = userIdProvider
    }

    // MARK: - Control

    func startSession(eventId: String) {
        Task { await healthKit.requestAuthorization() }
        logger.info("Starting Yoga session")
        reset()
        startDate = Date()
        isTracking = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            self.elapsedSeconds = Date().timeIntervalSince(start)
        }
    }

    func restoreStartDate(_ date: Date) {
        startDate = date
    }

    func endSession(event: EventFullDetails) async throws {
        timer?.invalidate()
        timer = nil
        isTracking = false

        guard let userId = userIdProvider() else {
            throw MetricsError.profileNotAvailable
        }

        if isCreator {
            try await creatorEndsSession(eventId: event.id, userId: userId)
        } else {
            try await participantEndsSession(eventId: event.id, userId: userId)
        }
    }

    // MARK: - Creator end

    private func creatorEndsSession(eventId: String, userId: String) async throws {
        let endDateTime = Date()

        let metrics = MetricsCollectedYoga(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            metricsCreatorType: .creator,
            numSession: numSessions
        )

        try await metrics.upload(eventId: eventId, userId: userId)
        try? await healthKit.saveTimeBasedWorkout(
            activityType: .yoga,
            start: startDateTime,
            end: endDateTime
        )

        let sessionEntry: [String: Any] = [
            "startDateTime": startDate as Any,
            "endDateTime": endDateTime
        ]

        let db = Firestore.firestore()
        try await db.collection("Events").document(eventId).updateData([
            "finalStartDateTime": startDate as Any,
            "finalEndDateTime": endDateTime,
            "status": UsersEventStatus.completed.rawValue,
            "numSessions": FieldValue.increment(Int64(1)),
            "sessionHistory": FieldValue.arrayUnion([sessionEntry])
        ])
    }

    // MARK: - Participant end

    private func participantEndsSession(eventId: String, userId: String) async throws {
        guard let finalEndDateTime = try await MetricsCollectorUtils
            .readFinalEndDateTime(eventId: eventId) else {
            logger.info("Yoga participant ended before creator — storing data only")
            let endNow = Date()
            try await MetricsCollectedYoga(
                startDateTime: startDateTime,
                endDateTime: endNow,
                metricsCreatorType: .normalParticipant,
                endedBeforeCreator: true,
                numSession: numSessions
            ).upload(eventId: eventId, userId: userId)
            try? await healthKit.saveTimeBasedWorkout(
                activityType: .yoga,
                start: startDateTime,
                end: endNow
            )
            return
        }

        try await MetricsCollectedYoga(
            startDateTime: startDateTime,
            endDateTime: finalEndDateTime,
            metricsCreatorType: .normalParticipant,
            endedBeforeCreator: false,
            numSession: numSessions
        ).upload(eventId: eventId, userId: userId)
        try? await healthKit.saveTimeBasedWorkout(
            activityType: .yoga,
            start: startDateTime,
            end: finalEndDateTime
        )

        logger.info("Yoga participant metrics uploaded")
    }

    // MARK: - Helpers

    private func reset() {
        elapsedSeconds = 0
        startDate = nil
    }
}
