//
//  MetricsCollectorSkiing.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import Foundation
struct SplitForSkiing: Identifiable, Codable {
    var id = UUID()
    let number: Int
    let speedKmH: Double
    let dateTimeCreated = Date()
}

import Foundation
import CoreLocation
import Combine
import OSLog
import FirebaseFirestore

@Observable
class MetricsCollectorSkiing: MetricsCollector {

    let startDateTime = Date()

    // MARK: - Public state
    var trackedLocations: [(Date, CLLocation)] = []
    var totalDistanceMeters: Double = 0
    var currentSpeedKmH: Double = 0
    var averageSpeedKmH: Double = 0
    var maxSpeedKmH: Double = -Double.infinity
    var verticalDropMeters: Double = 0
    var elevationGainMeters: Double = 0
    var numberOfRuns: Int = 0
    var splits: [SplitForSkiing] = []
    var elapsedSeconds: Double = 0
    var isTracking = false

    // MARK: - Private
    private let locationManager = LocationManager.shared
    private var lastLocation: CLLocation?
    private var startDate: Date?
    private var timer: Timer?
    private var distanceSinceLastSplit: Double = 0
    private var lastSplitDate: Date?
    private var isDescending = false          // true while altitude is dropping
    private var cancellables = Set<AnyCancellable>()
    private let splitEveryMeters: Double = 1000
    private let logger = Logger(subsystem: "sbud", category: "MetricsCollectorSkiing")
    let isCreator: Bool

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
        logger.info("Starting skiing session")
        reset()
        configureForSkiing()
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

        let metrics = MetricsCollectedSkiing(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            metricsCreatorType: .creator,
            track: track,
            totalDistance: totalDistanceMeters,
            verticalDrop: verticalDropMeters,
            elevationGain: elevationGainMeters,
            numberOfRuns: numberOfRuns,
            splits: splits
        )

        try await metrics.upload(eventId: eventId, userId: userId)

        let db = Firestore.firestore()
        try await db.collection("Events").document(eventId).updateData([
            "finalStartDateTime": startDate as Any,
            "finalEndDateTime": endDateTime,
            "status": UsersEventStatus.completed.rawValue,
            "avgSpeedKmH": averageSpeedKmH,
            "maxSpeedKmH": maxSpeedKmH == -.infinity ? 0.0 : maxSpeedKmH,
            "avgVerticalDrop": verticalDropMeters,
            "avgNumberOfRuns": numberOfRuns,
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
            logger.info("Skiing participant ended before creator — storing data only")
            let track = trackedLocations.map {
                TrackPoint(timestamp: $0.0,
                           latitude: $0.1.coordinate.latitude,
                           longitude: $0.1.coordinate.longitude)
            }
            let metrics = MetricsCollectedSkiing(
                startDateTime: startDateTime,
                endDateTime: Date(),
                metricsCreatorType: .normalParticipant,
                track: track,
                totalDistance: totalDistanceMeters,
                verticalDrop: verticalDropMeters,
                elevationGain: elevationGainMeters,
                numberOfRuns: numberOfRuns,
                splits: splits,
                endedBeforeCreator: true
            )
            try await metrics.upload(eventId: eventId, userId: userId)
            return
        }

        // Trim to finalEndDateTime
        let finalEndDateTime = (data["finalEndDateTime"] as! Timestamp).dateValue()

        let trimmedTrack = trackedLocations.filter { $0.0 <= finalEndDateTime }
        let trimmedSplits = splits.filter { $0.dateTimeCreated <= finalEndDateTime }
        let trimmedDistance = computeDistance(from: trimmedTrack.map { $0.1 })
        let trimmedVerticalDrop = computeVerticalDrop(from: trimmedTrack.map { $0.1 })
        let trimmedElevationGain = computeElevationGain(from: trimmedTrack.map { $0.1 })
        let trimmedRuns = computeNumberOfRuns(from: trimmedTrack.map { $0.1 })

        let trimmedElapsed: Double
        if let first = trimmedTrack.first?.0, let last = trimmedTrack.last?.0 {
            trimmedElapsed = last.timeIntervalSince(first)
        } else {
            trimmedElapsed = elapsedSeconds
        }

        let trimmedAvgSpeed = trimmedElapsed > 0
            ? (trimmedDistance / 1000) / (trimmedElapsed / 3600)
            : 0

        let trimmedMaxSpeed = trimmedSplits.map(\.speedKmH).max() ?? 0

        let trackPoints = trimmedTrack.map {
            TrackPoint(timestamp: $0.0,
                       latitude: $0.1.coordinate.latitude,
                       longitude: $0.1.coordinate.longitude)
        }

        let metrics = MetricsCollectedSkiing(
            startDateTime: startDateTime,
            endDateTime: finalEndDateTime,
            metricsCreatorType: .normalParticipant,
            track: trackPoints,
            totalDistance: trimmedDistance,
            verticalDrop: trimmedVerticalDrop,
            elevationGain: trimmedElevationGain,
            numberOfRuns: trimmedRuns,
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
                  let currentMaxSpeed = currentData["maxSpeedKmH"] as? Double,
                  let currentAvgDrop = currentData["avgVerticalDrop"] as? Double,
                  let currentAvgRuns = currentData["avgNumberOfRuns"] as? Double,
                  let currentCount = currentData["participantCount"] as? Int
            else {
                errorPointer?.pointee = NSError(
                    domain: "MetricsCollectorSkiing",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing metrics fields on event doc"]
                )
                return nil
            }

            let newCount = currentCount + 1
            let newAvgSpeed = (currentAvgSpeed * Double(currentCount) + trimmedAvgSpeed) / Double(newCount)
            let newMaxSpeed = max(currentMaxSpeed, trimmedMaxSpeed)
            let newAvgDrop = (currentAvgDrop * Double(currentCount) + trimmedVerticalDrop) / Double(newCount)
            let newAvgRuns = (currentAvgRuns * Double(currentCount) + Double(trimmedRuns)) / Double(newCount)

            transaction.updateData([
                "avgSpeedKmH": newAvgSpeed,
                "maxSpeedKmH": newMaxSpeed,
                "avgVerticalDrop": newAvgDrop,
                "avgNumberOfRuns": newAvgRuns,
                "participantCount": newCount
            ], forDocument: eventRef)

            return nil
        }

        logger.info("Skiing participant metrics uploaded and event averages updated")
    }

    // MARK: - Location config

    private func configureForSkiing() {
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

            let altDelta = location.altitude - last.altitude
            if altDelta < 0 {
                // Descending — on slope
                verticalDropMeters += abs(altDelta)
                if !isDescending {
                    isDescending = true
                    numberOfRuns += 1   // started a new descent
                }
            } else if altDelta > 0 {
                // Ascending — on lift
                elevationGainMeters += altDelta
                isDescending = false
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
        maxSpeedKmH = max(maxSpeedKmH, currentSpeedKmH)
    }

    private func updateAverageSpeed() {
        guard totalDistanceMeters > 0, elapsedSeconds > 0 else { return }
        averageSpeedKmH = (totalDistanceMeters / 1000) / (elapsedSeconds / 3600)
    }

    private func checkSplit(at location: CLLocation) {
        guard distanceSinceLastSplit >= splitEveryMeters,
              let splitStart = lastSplitDate else { return }

        let splitSeconds = location.timestamp.timeIntervalSince(splitStart)
        let speedKmH = splitSeconds > 0
            ? (distanceSinceLastSplit / 1000) / (splitSeconds / 3600)
            : 0

        splits.append(SplitForSkiing(number: splits.count + 1, speedKmH: speedKmH))
        distanceSinceLastSplit = 0
        lastSplitDate = location.timestamp
    }

    // MARK: - Trim helpers (recompute from raw locations)

    private func computeDistance(from locations: [CLLocation]) -> Double {
        guard locations.count > 1 else { return 0 }
        var total = 0.0
        for i in 1..<locations.count { total += locations[i].distance(from: locations[i - 1]) }
        return total
    }

    private func computeVerticalDrop(from locations: [CLLocation]) -> Double {
        guard locations.count > 1 else { return 0 }
        var drop = 0.0
        for i in 1..<locations.count {
            let delta = locations[i].altitude - locations[i - 1].altitude
            if delta < 0 { drop += abs(delta) }
        }
        return drop
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

    private func computeNumberOfRuns(from locations: [CLLocation]) -> Int {
        guard locations.count > 1 else { return 0 }
        var runs = 0
        var wasDescending = false
        for i in 1..<locations.count {
            let delta = locations[i].altitude - locations[i - 1].altitude
            if delta < 0 && !wasDescending {
                runs += 1
                wasDescending = true
            } else if delta >= 0 {
                wasDescending = false
            }
        }
        return runs
    }

    private func reset() {
        trackedLocations = []
        totalDistanceMeters = 0
        currentSpeedKmH = 0
        averageSpeedKmH = 0
        maxSpeedKmH = -.infinity
        verticalDropMeters = 0
        elevationGainMeters = 0
        numberOfRuns = 0
        splits = []
        elapsedSeconds = 0
        lastLocation = nil
        distanceSinceLastSplit = 0
        lastSplitDate = nil
        isDescending = false
    }
}
