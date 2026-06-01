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

    func startSession(eventId: String) {
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

    private func reset() {
        elapsedSeconds = 0
        startDate = nil
    }
}
