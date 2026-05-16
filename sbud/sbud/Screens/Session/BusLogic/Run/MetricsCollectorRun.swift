//
//  MetricsCollectorRun.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import Foundation
import CoreLocation
import Combine
import OSLog
import FirebaseFirestore

struct TrackPoint: Codable {
    let timestamp: Date
    let latitude: Double
    let longitude: Double
}

enum MetricsCreatorType: String, Codable{
    case creator = "Creator"
    case normalParticipant = "Normal Participant"
}
// creator is the one who ends it
// i link locations and distance by time,
// when calculating final metrics, i stop at the time of creator

// what are the final metrics per person?
// 0. time
// 1. track
// 2. total distance
// 3. average pace for each split

// what final metrics for the whole team
// 1. each one has their own track
// 2. average pace
// max, min pace

// 1. creator ends the session
// 2. creator saves data for time, track, total distance, averaage pace for each split
// 3. other participants will end too, they add their data, and update the average values
// 4. participants are queued, no parallel here
// 5. participants add data till the final date time set by the creator

// if participant ends the event before creator? their data is stored, but not included in the average
// if participant ends the event after creator? take data till final datetime set by creator
//
//  MetricsCollectorRun.swift
//  sbud
//

import Foundation
import CoreLocation
import Combine
import OSLog
import FirebaseFirestore

@Observable
class MetricsCollectorRun: MetricsCollector {

    let startDateTime = Date()

    // MARK: - Public state
    var trackedLocations: [(Date, CLLocation)] = []
    var totalDistanceMeters: Double = 0
    var splits: [Split] = []
    var currentPaceMinPerKm: Double = 0
    var averagePaceMinPerKm: Double = 0
    var elapsedSeconds: Double = 0
    var isTracking = false
    var minPace = Double.infinity
    var maxPace = -Double.infinity

    // MARK: - Private
    private let locationManager = LocationManager.shared
    private var lastLocation: CLLocation?
    private var startDate: Date?
    private var timer: Timer?
    private var distanceSinceLastSplit: Double = 0
    private var lastSplitDate: Date?
    private var cancellables = Set<AnyCancellable>()
    private let splitEveryMeters: Double = 1000
    let isCreator: Bool
    private let logger = Logger(subsystem: "sbud", category: "MetricsCollectorRun")

    init(isCreator: Bool) {
        self.isCreator = isCreator
        locationManager.$lastLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.handleNewLocation(location)
            }
            .store(in: &cancellables)
    }

    // MARK: - Control

    func startSession() {
        logger.info("Starting running session")
        reset()
        configureForRun()
        locationManager.startUpdating()
        startDate = Date()
        lastSplitDate = Date()
        isTracking = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            self.elapsedSeconds = Date().timeIntervalSince(start)
            self.updateAveragePace()
        }
    }

    func endSession(event: EventFullDetails) async throws {
        restoreDefaultConfig()
        locationManager.stopUpdating()
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

        let track = trackedLocations.map {
            TrackPoint(timestamp: $0.0,
                       latitude: $0.1.coordinate.latitude,
                       longitude: $0.1.coordinate.longitude)
        }

        let metrics = MetricsCollectedRun(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            metricsCreatorType: .creator,
            track: track,
            totalDistance: totalDistanceMeters,
            splits: splits
        )

        try await metrics.upload(eventId: eventId, userId: userId)

        let db = Firestore.firestore()
        let eventRef = db.collection("Events").document(eventId)

        try await eventRef.updateData([
            "finalStartDateTime": startDate as Any,
            "finalEndDateTime": endDateTime,
            "status": UsersEventStatus.completed.rawValue,
            "avgPace": averagePaceMinPerKm,
            "minPace": minPace == .infinity ? 0.0 : minPace,
            "maxPace": maxPace == -.infinity ? 0.0 : maxPace,
            "participantCount": FieldValue.increment(Int64(1))  // track how many contributed to avg
        ])
    }

    // MARK: - Participant end

    private func participantEndsSession(eventId: String, userId: String) async throws {
        let db = Firestore.firestore()
        let eventRef = db.collection("Events").document(eventId)

        // 1. Read the event doc to check if creator has ended
        let snapshot = try await eventRef.getDocument()
        guard let data = snapshot.data() else {
            throw MetricsError.eventNotFound
        }

        let creatorEndedSession = data["finalEndDateTime"] != nil

        if !creatorEndedSession {
            // Creator hasn't ended yet — upload as-is, excluded from averages
            logger.info("Participant ended before creator — storing data, skipping avg update")

            let track = trackedLocations.map {
                TrackPoint(timestamp: $0.0,
                           latitude: $0.1.coordinate.latitude,
                           longitude: $0.1.coordinate.longitude)
            }

            let metrics = MetricsCollectedRun(
                startDateTime: startDateTime,
                endDateTime: Date(),
                metricsCreatorType: .normalParticipant,
                track: track,
                totalDistance: totalDistanceMeters,
                splits: splits,
                endedBeforeCreator: true
            )

            try await metrics.upload(eventId: eventId, userId: userId)
            return
        }

        // 2. Creator has ended — trim data to finalEndDateTime
        let finalEndDateTime = (data["finalEndDateTime"] as! Timestamp).dateValue()

        let trimmedTrack = trackedLocations.filter { $0.0 <= finalEndDateTime }
        let trimmedSplits = splits.filter { $0.dateTimeCreated <= finalEndDateTime }

        // Recalculate total distance from trimmed track
        let trimmedDistance = computeDistance(from: trimmedTrack.map { $0.1 })

        // Recalculate average pace from trimmed data
        let trimmedElapsed: Double
        if let first = trimmedTrack.first?.0, let last = trimmedTrack.last?.0 {
            trimmedElapsed = last.timeIntervalSince(first)
        } else {
            trimmedElapsed = elapsedSeconds
        }
        let trimmedAvgPace = trimmedDistance > 0
            ? (trimmedElapsed / 60) / (trimmedDistance / 1000)
            : 0

        let trackPoints = trimmedTrack.map {
            TrackPoint(timestamp: $0.0,
                       latitude: $0.1.coordinate.latitude,
                       longitude: $0.1.coordinate.longitude)
        }

        let metrics = MetricsCollectedRun(
            startDateTime: startDateTime,
            endDateTime: finalEndDateTime,
            metricsCreatorType: .normalParticipant,
            track: trackPoints,
            totalDistance: trimmedDistance,
            splits: trimmedSplits,
            endedBeforeCreator: false
        )

        try await metrics.upload(eventId: eventId, userId: userId)

        // 3. Transaction: read current avg/min/max, include this participant, write back
        guard trimmedAvgPace > 0 else {
            logger.warning("Participant avg pace is 0, skipping event metrics update")
            return
        }

        let participantMinPace = trimmedSplits.map(\.paceInMinPerKm).min() ?? trimmedAvgPace
        let participantMaxPace = trimmedSplits.map(\.paceInMinPerKm).max() ?? trimmedAvgPace

        _ = try await db.runTransaction { transaction, errorPointer in
            let eventSnap: DocumentSnapshot
            do {
                eventSnap = try transaction.getDocument(eventRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let currentData = eventSnap.data(),
                  let currentAvg = currentData["avgPace"] as? Double,
                  let currentMin = currentData["minPace"] as? Double,
                  let currentMax = currentData["maxPace"] as? Double,
                  let currentCount = currentData["participantCount"] as? Int
            else {
                let error = NSError(
                    domain: "MetricsCollectorRun",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing metrics fields on event doc"]
                )
                errorPointer?.pointee = error
                return nil
            }

            // Simple average: (existingAvg * existingCount + newAvg) / (existingCount + 1)
            let newCount = currentCount + 1
            let newAvg = (currentAvg * Double(currentCount) + trimmedAvgPace) / Double(newCount)
            let newMin = min(currentMin, participantMinPace)
            let newMax = max(currentMax, participantMaxPace)

            transaction.updateData([
                "avgPace": newAvg,
                "minPace": newMin,
                "maxPace": newMax,
                "participantCount": newCount
            ], forDocument: eventRef)

            return nil
        }

        logger.info("Participant metrics uploaded and event averages updated")
    }

    // MARK: - Helpers

    private func computeDistance(from locations: [CLLocation]) -> Double {
        guard locations.count > 1 else { return 0 }
        var total = 0.0
        for i in 1..<locations.count {
            total += locations[i].distance(from: locations[i - 1])
        }
        return total
    }

    // MARK: - Location config

    private func configureForRun() {
        locationManager.applyConfiguration {
            $0.activityType = .fitness
            $0.distanceFilter = 5
            $0.pausesLocationUpdatesAutomatically = false
            let status = $0.authorizationStatus
            $0.allowsBackgroundLocationUpdates = (status == .authorizedAlways)
        }
    }

    private func restoreDefaultConfig() {
        locationManager.applyConfiguration {
            $0.activityType = .other
            $0.distanceFilter = kCLDistanceFilterNone
            $0.allowsBackgroundLocationUpdates = false
            $0.pausesLocationUpdatesAutomatically = true
        }
    }

    // MARK: - Location handling

    private func handleNewLocation(_ location: CLLocation) {
        guard isTracking, isValid(location) else { return }

        trackedLocations.append((Date(), location))

        if let last = lastLocation {
            let delta = location.distance(from: last)
            totalDistanceMeters += delta
            distanceSinceLastSplit += delta
            updateCurrentPace(from: location)
            checkSplit(at: location)
        }

        lastLocation = location
    }

    private func isValid(_ location: CLLocation) -> Bool {
        guard location.horizontalAccuracy >= 0,
              location.horizontalAccuracy < 20,
              location.speed >= 0
        else { return false }

        if let last = lastLocation {
            let timeDelta = location.timestamp.timeIntervalSince(last.timestamp)
            guard timeDelta >= 1 else { return false }
        }

        return true
    }

    private func updateCurrentPace(from location: CLLocation) {
        guard location.speed > 0.5 else { return }
        currentPaceMinPerKm = (1000 / location.speed) / 60
    }

    private func updateAveragePace() {
        guard totalDistanceMeters > 0 else { return }
        averagePaceMinPerKm = (elapsedSeconds / 60) / (totalDistanceMeters / 1000)
        minPace = min(minPace, averagePaceMinPerKm)
        maxPace = max(maxPace, averagePaceMinPerKm)
    }

    private func checkSplit(at location: CLLocation) {
        guard distanceSinceLastSplit >= splitEveryMeters,
              let splitStart = lastSplitDate else { return }

        let splitSeconds = location.timestamp.timeIntervalSince(splitStart)
        let pace = (splitSeconds / 60) / (distanceSinceLastSplit / 1000)

        splits.append(Split(number: splits.count + 1, paceInMinPerKm: pace))
        distanceSinceLastSplit = 0
        lastSplitDate = location.timestamp
    }

    private func reset() {
        trackedLocations = []
        totalDistanceMeters = 0
        splits = []
        currentPaceMinPerKm = 0
        averagePaceMinPerKm = 0
        elapsedSeconds = 0
        lastLocation = nil
        distanceSinceLastSplit = 0
        lastSplitDate = nil
    }
}

// MARK: - Errors

enum MetricsError: Error {
    case eventNotFound
}
