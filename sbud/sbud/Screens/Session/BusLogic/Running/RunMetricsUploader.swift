//
//  RunMetricsUploader.swift
//  sbud
//
//  Created by ahmed on 31/05/2026.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import OSLog

/// Stateless upload helpers that work from a persisted `RunSessionSnapshot`.
///
/// Separated from `MetricsCollectorRun` so the retry service (and unit tests)
/// can exercise upload logic without instantiating a live collector.
enum RunMetricsUploader {

    private static let logger = Logger(subsystem: "sbud", category: "RunMetricsUploader")

    // MARK: - Creator

    /// Rebuilds and uploads the creator's metrics, then updates the Event document.
    static func uploadCreator(
        snapshot: RunSessionSnapshot,
        eventUpdate: CreatorEventUpdate,
        userId: String
    ) async throws {
        logger.info("Uploading creator run metrics for event \(snapshot.eventId)")

        let metrics = MetricsCollectedRun(
            userId: userId,
            startDateTime: snapshot.startDate,
            endDateTime: eventUpdate.finalEndDateTime,
            metricsCreatorType: .creator,
            track: snapshot.trackPoints,
            totalDistance: snapshot.totalDistanceMeters,
            splits: snapshot.splits,
            numSession: eventUpdate.numSession
        )

        try await metrics.upload(eventId: snapshot.eventId, userId: userId)

        let sessionEntry: [String: Any] = [
            "startDateTime": eventUpdate.finalStartDateTime,
            "endDateTime": eventUpdate.finalEndDateTime
        ]

        let db = Firestore.firestore()
        try await db.collection("Events").document(snapshot.eventId).updateData([
            "finalStartDateTime": eventUpdate.finalStartDateTime,
            "finalEndDateTime": eventUpdate.finalEndDateTime,
            "status": UsersEventStatus.completed.rawValue,
            "numSessions": FieldValue.increment(Int64(1)),
            "sessionHistory": FieldValue.arrayUnion([sessionEntry])
        ])

        logger.info("Creator run upload complete for event \(snapshot.eventId)")
    }

    // MARK: - Participant

    /// Uploads participant metrics trimmed (or not) against `finalEndDateTime`.
    /// Mirrors the logic in `MetricsCollectorRun.uploadParticipantMetrics` but
    /// works entirely from the persisted snapshot.
    static func uploadParticipant(
        snapshot: RunSessionSnapshot,
        finalEndDateTime: Date,
        userId: String,
        numSession: Int
    ) async throws {
        logger.info("Uploading participant run metrics for event \(snapshot.eventId)")

        let participantEndDateTime = snapshot.startDate.addingTimeInterval(snapshot.elapsedSeconds)
        let endedBeforeCreator = participantEndDateTime <= finalEndDateTime

        let finalTrack: [TrackPoint]
        let finalSplits: [Split]
        let finalDistance: Double
        let finalEndTime: Date

        if endedBeforeCreator {
            logger.info("Participant ended before creator for event \(snapshot.eventId) — using full data")
            finalTrack = snapshot.trackPoints
            finalSplits = snapshot.splits
            finalDistance = snapshot.totalDistanceMeters
            finalEndTime = participantEndDateTime
        } else {
            logger.info("Participant ran past creator end for event \(snapshot.eventId) — trimming data")
            let locationTuples = snapshot.trackPoints.map { point -> (Date, CLLocation) in
                let loc = CLLocation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: point.latitude,
                        longitude: point.longitude
                    ),
                    altitude: 0,
                    horizontalAccuracy: 10,
                    verticalAccuracy: 10,
                    timestamp: point.timestamp
                )
                return (point.timestamp, loc)
            }
            let trimmed = MetricsCollectorUtils.trimTrack(locationTuples, to: finalEndDateTime)
            finalSplits = snapshot.splits.filter { $0.dateTimeCreated <= finalEndDateTime }
            finalDistance = MetricsCollectorUtils.computeDistance(from: trimmed.map { $0.1 })
            finalTrack = trimmed.toTrackPoints()
            finalEndTime = finalEndDateTime
        }

        let metrics = MetricsCollectedRun(
            userId: userId,
            startDateTime: snapshot.startDate,
            endDateTime: finalEndTime,
            metricsCreatorType: .normalParticipant,
            track: finalTrack,
            totalDistance: finalDistance,
            splits: finalSplits,
            endedBeforeCreator: endedBeforeCreator,
            numSession: numSession
        )

        try await metrics.upload(eventId: snapshot.eventId, userId: userId)
        logger.info("Participant run upload complete for event \(snapshot.eventId)")
    }

    // MARK: - Participant fallback (24 h timeout)

    /// Used when the creator never ended after 24 hours.
    /// Uploads with the participant's own end time and marks as early exit.
    static func uploadParticipantFallback(
        snapshot: RunSessionSnapshot,
        userId: String,
        numSession: Int
    ) async throws {
        logger.warning("Uploading participant fallback for event \(snapshot.eventId) — creator never ended")

        let fallbackEnd = snapshot.startDate.addingTimeInterval(snapshot.elapsedSeconds)

        let metrics = MetricsCollectedRun(
            userId: userId,
            startDateTime: snapshot.startDate,
            endDateTime: fallbackEnd,
            metricsCreatorType: .normalParticipant,
            track: snapshot.trackPoints,
            totalDistance: snapshot.totalDistanceMeters,
            splits: snapshot.splits,
            endedBeforeCreator: true,
            numSession: numSession
        )

        try await metrics.upload(eventId: snapshot.eventId, userId: userId)
        logger.info("Participant fallback upload complete for event \(snapshot.eventId)")
    }
}
