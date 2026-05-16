//
//  MetricsCollectorSwimming.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//


import Foundation
import OSLog
import FirebaseFirestore

@Observable
class MetricsCollectorSwimming: MetricsCollector {

    let startDateTime = Date()

    // MARK: - Public state
    var elapsedSeconds: Double = 0
    var isTracking = false

    // MARK: - Private
    private var startDate: Date?
    private var timer: Timer?
    let isCreator: Bool
    private let logger = Logger(subsystem: "sbud", category: "MetricsCollectorSwimming")

    init(isCreator: Bool) {
        self.isCreator = isCreator
    }

    // MARK: - Control

    func startSession() {
        logger.info("Starting swimming session")
        reset()
        startDate = Date()
        isTracking = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            self.elapsedSeconds = Date().timeIntervalSince(start)
        }
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

        let metrics = MetricsCollectedSwimming(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            metricsCreatorType: .creator
        )

        try await metrics.upload(eventId: eventId, userId: userId)

        let db = Firestore.firestore()
        try await db.collection("Events").document(eventId).updateData([
            "finalStartDateTime": startDate as Any,
            "finalEndDateTime": endDateTime,
            "status": UsersEventStatus.completed.rawValue
        ])
    }

    // MARK: - Participant end

    private func participantEndsSession(eventId: String, userId: String) async throws {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("Events").document(eventId).getDocument()

        guard let data = snapshot.data() else { throw MetricsError.eventNotFound }

        let creatorEndedSession = data["finalEndDateTime"] != nil

        if !creatorEndedSession {
            logger.info("Swimming participant ended before creator — storing data only")
            let metrics = MetricsCollectedSwimming(
                startDateTime: startDateTime,
                endDateTime: Date(),
                metricsCreatorType: .normalParticipant,
                endedBeforeCreator: true
            )
            try await metrics.upload(eventId: eventId, userId: userId)
            return
        }

        let finalEndDateTime = (data["finalEndDateTime"] as! Timestamp).dateValue()

        let metrics = MetricsCollectedSwimming(
            startDateTime: startDateTime,
            endDateTime: finalEndDateTime,
            metricsCreatorType: .normalParticipant,
            endedBeforeCreator: false
        )

        try await metrics.upload(eventId: eventId, userId: userId)
        logger.info("Swimming participant metrics uploaded")
    }

    // MARK: - Helpers

    private func reset() {
        elapsedSeconds = 0
        startDate = nil
    }
}
