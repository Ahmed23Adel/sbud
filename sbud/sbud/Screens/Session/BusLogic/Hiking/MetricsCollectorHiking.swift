//
//  MetricsCollectorHiking.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import Foundation
import CoreLocation
import Combine
import OSLog
import FirebaseFirestore

struct SplitForHiking: Identifiable, Codable {
    var id = UUID()
    let number: Int
    let paceMinPerKm: Double
    let dateTimeCreated = Date()
}

@Observable
class MetricsCollectorHiking: MetricsCollector {

    let startDateTime = Date()

    // MARK: - Public state
    var trackedLocations: [(Date, CLLocation)] = []
    var totalDistanceMeters: Double = 0
    var currentSpeedKmH: Double = 0
    var averageSpeedKmH: Double = 0
    var elevationGainMeters: Double = 0
    var elevationLossMeters: Double = 0
    var maxAltitudeMeters: Double = -Double.infinity
    var currentAltitudeMeters: Double = 0
    var splits: [SplitForHiking] = []
    var elapsedSeconds: Double = 0
    var isTracking = false

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
    private let logger = Logger(subsystem: "sbud", category: "MetricsCollectorHiking")

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
        logger.info("Starting hiking session")
        reset()
        configureForHiking()
        locationManager.startUpdating()
        startDate = Date()
        lastSplitDate = Date()
        isTracking = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            self.elapsedSeconds = Date().timeIntervalSince(start)
            self.updateAverageSpeed()
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

        let metrics = MetricsCollectedHiking(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            metricsCreatorType: .creator,
            track: track,
            totalDistance: totalDistanceMeters,
            elevationGain: elevationGainMeters,
            elevationLoss: elevationLossMeters,
            maxAltitude: maxAltitudeMeters == -.infinity ? 0 : maxAltitudeMeters,
            splits: splits
        )

        try await metrics.upload(eventId: eventId, userId: userId)

        let db = Firestore.firestore()
        try await db.collection("Events").document(eventId).updateData([
            "finalStartDateTime": startDate as Any,
            "finalEndDateTime": endDateTime,
            "status": UsersEventStatus.completed.rawValue,
            "avgSpeedKmH": averageSpeedKmH,
            "avgElevationGain": elevationGainMeters,
            "avgElevationLoss": elevationLossMeters,
            "avgMaxAltitude": maxAltitudeMeters == -.infinity ? 0.0 : maxAltitudeMeters,
            "participantCount": FieldValue.increment(Int64(1))
        ])
    }

    // MARK: - Participant end

    private func participantEndsSession(eventId: String, userId: String) async throws {
        let db = Firestore.firestore()
        let eventRef = db.collection("Events").document(eventId)

        let snapshot = try await eventRef.getDocument()
        guard let data = snapshot.data() else { throw MetricsError.eventNotFound }

        let creatorEndedSession = data["finalEndDateTime"] != nil

        if !creatorEndedSession {
            logger.info("Hiking participant ended before creator — storing data only")
            let track = trackedLocations.map {
                TrackPoint(timestamp: $0.0,
                           latitude: $0.1.coordinate.latitude,
                           longitude: $0.1.coordinate.longitude)
            }
            let metrics = MetricsCollectedHiking(
                startDateTime: startDateTime,
                endDateTime: Date(),
                metricsCreatorType: .normalParticipant,
                track: track,
                totalDistance: totalDistanceMeters,
                elevationGain: elevationGainMeters,
                elevationLoss: elevationLossMeters,
                maxAltitude: maxAltitudeMeters == -.infinity ? 0 : maxAltitudeMeters,
                splits: splits,
                endedBeforeCreator: true
            )
            try await metrics.upload(eventId: eventId, userId: userId)
            return
        }

        let finalEndDateTime = (data["finalEndDateTime"] as! Timestamp).dateValue()

        let trimmedTrack = trackedLocations.filter { $0.0 <= finalEndDateTime }
        let trimmedSplits = splits.filter { $0.dateTimeCreated <= finalEndDateTime }
        let trimmedDistance = computeDistance(from: trimmedTrack.map { $0.1 })
        let trimmedElevationGain = computeElevationGain(from: trimmedTrack.map { $0.1 })
        let trimmedElevationLoss = computeElevationLoss(from: trimmedTrack.map { $0.1 })
        let trimmedMaxAltitude = trimmedTrack.map { $0.1.altitude }.max() ?? 0

        let trimmedElapsed: Double
        if let first = trimmedTrack.first?.0, let last = trimmedTrack.last?.0 {
            trimmedElapsed = last.timeIntervalSince(first)
        } else {
            trimmedElapsed = elapsedSeconds
        }

        let trimmedAvgSpeed = trimmedElapsed > 0
            ? (trimmedDistance / 1000) / (trimmedElapsed / 3600)
            : 0

        let trackPoints = trimmedTrack.map {
            TrackPoint(timestamp: $0.0,
                       latitude: $0.1.coordinate.latitude,
                       longitude: $0.1.coordinate.longitude)
        }

        let metrics = MetricsCollectedHiking(
            startDateTime: startDateTime,
            endDateTime: finalEndDateTime,
            metricsCreatorType: .normalParticipant,
            track: trackPoints,
            totalDistance: trimmedDistance,
            elevationGain: trimmedElevationGain,
            elevationLoss: trimmedElevationLoss,
            maxAltitude: trimmedMaxAltitude,
            splits: trimmedSplits,
            endedBeforeCreator: false
        )

        try await metrics.upload(eventId: eventId, userId: userId)

        guard trimmedAvgSpeed > 0 else {
            logger.warning("Participant avg speed is 0, skipping event metrics update")
            return
        }

        _ = try await db.runTransaction { transaction, errorPointer in
            let eventSnap: DocumentSnapshot
            do {
                eventSnap = try transaction.getDocument(eventRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let currentData = eventSnap.data(),
                  let currentAvgSpeed = currentData["avgSpeedKmH"] as? Double,
                  let currentAvgGain = currentData["avgElevationGain"] as? Double,
                  let currentAvgLoss = currentData["avgElevationLoss"] as? Double,
                  let currentAvgAltitude = currentData["avgMaxAltitude"] as? Double,
                  let currentCount = currentData["participantCount"] as? Int
            else {
                errorPointer?.pointee = NSError(
                    domain: "MetricsCollectorHiking",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing metrics fields on event doc"]
                )
                return nil
            }

            let newCount = currentCount + 1
            let newAvgSpeed = (currentAvgSpeed * Double(currentCount) + trimmedAvgSpeed) / Double(newCount)
            let newAvgGain = (currentAvgGain * Double(currentCount) + trimmedElevationGain) / Double(newCount)
            let newAvgLoss = (currentAvgLoss * Double(currentCount) + trimmedElevationLoss) / Double(newCount)
            let newAvgAltitude = (currentAvgAltitude * Double(currentCount) + trimmedMaxAltitude) / Double(newCount)

            transaction.updateData([
                "avgSpeedKmH": newAvgSpeed,
                "avgElevationGain": newAvgGain,
                "avgElevationLoss": newAvgLoss,
                "avgMaxAltitude": newAvgAltitude,
                "participantCount": newCount
            ], forDocument: eventRef)

            return nil
        }

        logger.info("Hiking participant metrics uploaded and event averages updated")
    }

    // MARK: - Location config

    private func configureForHiking() {
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
        currentAltitudeMeters = location.altitude
        maxAltitudeMeters = max(maxAltitudeMeters, location.altitude)

        if let last = lastLocation {
            let delta = location.distance(from: last)
            totalDistanceMeters += delta
            distanceSinceLastSplit += delta

            let altDelta = location.altitude - last.altitude
            if altDelta > 0 {
                elevationGainMeters += altDelta
            } else {
                elevationLossMeters += abs(altDelta)
            }

            updateCurrentSpeed(from: location)
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

    private func updateCurrentSpeed(from location: CLLocation) {
        guard location.speed > 0 else { return }
        currentSpeedKmH = location.speed * 3.6
    }

    private func updateAverageSpeed() {
        guard totalDistanceMeters > 0, elapsedSeconds > 0 else { return }
        averageSpeedKmH = (totalDistanceMeters / 1000) / (elapsedSeconds / 3600)
    }

    private func checkSplit(at location: CLLocation) {
        guard distanceSinceLastSplit >= splitEveryMeters,
              let splitStart = lastSplitDate else { return }

        let splitSeconds = location.timestamp.timeIntervalSince(splitStart)
        let pace = splitSeconds > 0
            ? (splitSeconds / 60) / (distanceSinceLastSplit / 1000)
            : 0

        splits.append(SplitForHiking(number: splits.count + 1, paceMinPerKm: pace))
        distanceSinceLastSplit = 0
        lastSplitDate = location.timestamp
    }

    // MARK: - Trim helpers

    private func computeDistance(from locations: [CLLocation]) -> Double {
        guard locations.count > 1 else { return 0 }
        var total = 0.0
        for i in 1..<locations.count { total += locations[i].distance(from: locations[i - 1]) }
        return total
    }

    private func computeElevationGain(from locations: [CLLocation]) -> Double {
        guard locations.count > 1 else { return 0 }
        var gain = 0.0
        for i in 1..<locations.count {
            let delta = locations[i].altitude - locations[i - 1].altitude
            if delta > 0 { gain += delta }
        }
        return gain
    }

    private func computeElevationLoss(from locations: [CLLocation]) -> Double {
        guard locations.count > 1 else { return 0 }
        var loss = 0.0
        for i in 1..<locations.count {
            let delta = locations[i].altitude - locations[i - 1].altitude
            if delta < 0 { loss += abs(delta) }
        }
        return loss
    }

    private func reset() {
        trackedLocations = []
        totalDistanceMeters = 0
        currentSpeedKmH = 0
        averageSpeedKmH = 0
        elevationGainMeters = 0
        elevationLossMeters = 0
        maxAltitudeMeters = -.infinity
        currentAltitudeMeters = 0
        splits = []
        elapsedSeconds = 0
        lastLocation = nil
        distanceSinceLastSplit = 0
        lastSplitDate = nil
    }
}
