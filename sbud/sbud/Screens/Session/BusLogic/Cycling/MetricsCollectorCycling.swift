//
//  MetricsCollectorCycling.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import Foundation
import CoreLocation
import Combine
import OSLog
import FirebaseFirestore

struct SplitForCycling: Identifiable, Codable {
    var id = UUID()
    let number: Int
    let paceInMinPerKm: Double   // used by running
    let speedKmH: Double         // used by cycling; pass 0 for running splits
    let dateTimeCreated = Date()

    var formattedPace: String {
        let mins = Int(paceInMinPerKm)
        let secs = Int((paceInMinPerKm - Double(mins)) * 60)
        return String(format: "%d'%02d\"/km", mins, secs)
    }
}

@Observable
class MetricsCollectorCycling: MetricsCollector, MetricsCollectorTimeable, MetricsCollectorPersistable {

    let startDateTime = Date()

    // MARK: - Public state
    var trackedLocations: [(Date, CLLocation)] = []
    var totalDistanceMeters: Double = 0
    var currentSpeedKmH: Double = 0
    var averageSpeedKmH: Double = 0
    var elevationGainMeters: Double = 0
    var splits: [SplitForCycling] = []
    var elapsedSeconds: Double = 0
    var isTracking = false
    var minSpeedKmH: Double = Double.infinity
    var maxSpeedKmH: Double = -Double.infinity

    // MARK: - Private
    private let locationManager = LocationManager.shared
    private var lastLocation: CLLocation?
    private var startDate: Date?
    private var timer: Timer?
    private var checkpointTimer: Timer?
    private var distanceSinceLastSplit: Double = 0
    private var lastSplitDate: Date?
    private var currentEventId: String?
    private var cancellables = Set<AnyCancellable>()
    private let splitEveryMeters: Double = 1000
    private let checkpointIntervalSeconds: Double = 30
    let isCreator: Bool
    private let numSessions: Int
    private let logger = Logger(subsystem: "sbud", category: "MetricsCollectorCycling")

    init(isCreator: Bool, numSessions: Int) {
        self.isCreator = isCreator
        self.numSessions = numSessions
        locationManager.$lastLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.handleNewLocation(location)
            }
            .store(in: &cancellables)
    }

    // MARK: - Control

    func startSession(eventId: String) {
        currentEventId = eventId

        if restoreCheckpoint(eventId: eventId) {
            logger.info("Restored crash checkpoint for eventId: \(eventId)")
        } else {
            logger.info("No checkpoint found, starting fresh")
            reset()
            startDate = Date()
            lastSplitDate = Date()
        }

        configureForCycling()
        locationManager.startUpdating()
        isTracking = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            self.elapsedSeconds = Date().timeIntervalSince(start)
            self.updateAverageSpeed()
        }

        checkpointTimer = Timer.scheduledTimer(
            withTimeInterval: checkpointIntervalSeconds,
            repeats: true
        ) { [weak self] _ in
            guard let self, let eventId = self.currentEventId else { return }
            self.saveCheckpoint(eventId: eventId)
        }
    }

    func endSession(event: EventFullDetails) async throws {
        restoreDefaultConfig()
        locationManager.stopUpdating()
        timer?.invalidate()
        timer = nil
        checkpointTimer?.invalidate()
        checkpointTimer = nil
        isTracking = false

        let userId = ProfileManager.shared.getLocalProfile()!.id

        if isCreator {
            try await creatorEndsSession(eventId: event.id, userId: userId)
        } else {
            try await participantEndsSession(eventId: event.id, userId: userId)
        }

        clearCheckpoint(eventId: event.id)
    }

    // MARK: - Checkpoint persistence

    func saveCheckpoint(eventId: String) {
        guard let startDate else { return }

        let snapshot = CyclingSessionSnapshot(
            eventId: eventId,
            startDate: startDate,
            lastSplitDate: lastSplitDate,
            totalDistanceMeters: totalDistanceMeters,
            distanceSinceLastSplit: distanceSinceLastSplit,
            elevationGainMeters: elevationGainMeters,
            elapsedSeconds: elapsedSeconds,
            minSpeedKmH: minSpeedKmH,
            maxSpeedKmH: maxSpeedKmH,
            splits: splits,
            trackPoints: trackedLocations.toTrackPoints()
        )

        guard let data = try? JSONEncoder().encode(snapshot) else {
            logger.error("Failed to encode CyclingSessionSnapshot")
            return
        }

        UserDefaults.standard.set(data, forKey: checkpointKey(eventId: eventId))
        logger.info("Checkpoint saved for eventId: \(eventId), \(self.trackedLocations.count) points")
    }

    func restoreCheckpoint(eventId: String) -> Bool {
        guard let data = UserDefaults.standard.data(forKey: checkpointKey(eventId: eventId)),
              let snapshot = try? JSONDecoder().decode(CyclingSessionSnapshot.self, from: data)
        else { return false }

        startDate = snapshot.startDate
        lastSplitDate = snapshot.lastSplitDate
        totalDistanceMeters = snapshot.totalDistanceMeters
        distanceSinceLastSplit = snapshot.distanceSinceLastSplit
        elevationGainMeters = snapshot.elevationGainMeters
        elapsedSeconds = snapshot.elapsedSeconds
        minSpeedKmH = snapshot.minSpeedKmH
        maxSpeedKmH = snapshot.maxSpeedKmH
        splits = snapshot.splits

        trackedLocations = snapshot.trackPoints.map { point in
            let location = CLLocation(
                coordinate: CLLocationCoordinate2D(
                    latitude: point.latitude,
                    longitude: point.longitude
                ),
                altitude: 0,
                horizontalAccuracy: 10,
                verticalAccuracy: 10,
                timestamp: point.timestamp
            )
            return (point.timestamp, location)
        }

        lastLocation = trackedLocations.last?.1
        return true
    }

    // MARK: - Creator end

    private func creatorEndsSession(eventId: String, userId: String) async throws {
        let endDateTime = Date()

        let metrics = MetricsCollectedCycling(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            metricsCreatorType: .creator,
            track: trackedLocations.toTrackPoints(),
            totalDistance: totalDistanceMeters,
            elevationGain: elevationGainMeters,
            splits: splits,
            numSession: numSessions
        )

        try await metrics.upload(eventId: eventId, userId: userId)

        let db = Firestore.firestore()
        try await db.collection("Events").document(eventId).updateData([
            "finalStartDateTime": startDate as Any,
            "finalEndDateTime": endDateTime,
            "status": UsersEventStatus.completed.rawValue,
            "avgSpeedKmH": averageSpeedKmH,
            "minSpeedKmH": minSpeedKmH == .infinity ? 0.0 : minSpeedKmH,
            "maxSpeedKmH": maxSpeedKmH == -.infinity ? 0.0 : maxSpeedKmH,
            "participantCount": FieldValue.increment(Int64(1)),
            "numSessions": numSessions + 1
        ])
    }

    // MARK: - Participant end

    private func participantEndsSession(eventId: String, userId: String) async throws {
        let db = Firestore.firestore()
        let eventRef = db.collection("Events").document(eventId)

        guard let finalEndDateTime = try await MetricsCollectorUtils.readFinalEndDateTime(eventId: eventId) else {
            logger.info("Cycling participant ended before creator — storing data only")
            let metrics = MetricsCollectedCycling(
                startDateTime: startDateTime,
                endDateTime: Date(),
                metricsCreatorType: .normalParticipant,
                track: trackedLocations.toTrackPoints(),
                totalDistance: totalDistanceMeters,
                elevationGain: elevationGainMeters,
                splits: splits,
                endedBeforeCreator: true,
                numSession: numSessions
            )
            try await metrics.upload(eventId: eventId, userId: userId)
            return
        }

        let trimmedTrack = MetricsCollectorUtils.trimTrack(trackedLocations, to: finalEndDateTime)
        let trimmedSplits = splits.filter { $0.dateTimeCreated <= finalEndDateTime }
        let trimmedDistance = MetricsCollectorUtils.computeDistance(from: trimmedTrack.map { $0.1 })
        let trimmedElevation = MetricsCollectorUtils.computeElevationGain(from: trimmedTrack.map { $0.1 })
        let trimmedElapsed = MetricsCollectorUtils.trimmedElapsed(from: trimmedTrack, fallback: elapsedSeconds)
        let trimmedAvgSpeed = trimmedElapsed > 0
            ? (trimmedDistance / 1000) / (trimmedElapsed / 3600)
            : 0

        let metrics = MetricsCollectedCycling(
            startDateTime: startDateTime,
            endDateTime: finalEndDateTime,
            metricsCreatorType: .normalParticipant,
            track: trimmedTrack.toTrackPoints(),
            totalDistance: trimmedDistance,
            elevationGain: trimmedElevation,
            splits: trimmedSplits,
            endedBeforeCreator: false,
            numSession: numSessions
        )
        try await metrics.upload(eventId: eventId, userId: userId)

        guard trimmedAvgSpeed > 0 else {
            logger.warning("Participant avg speed is 0, skipping event metrics update")
            return
        }

        let participantMinSpeed = trimmedSplits.map(\.speedKmH).min() ?? trimmedAvgSpeed
        let participantMaxSpeed = trimmedSplits.map(\.speedKmH).max() ?? trimmedAvgSpeed

        _ = try await db.runTransaction { transaction, errorPointer in
            let eventSnap: DocumentSnapshot
            do {
                eventSnap = try transaction.getDocument(eventRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let currentData = eventSnap.data(),
                  let currentAvg = currentData["avgSpeedKmH"] as? Double,
                  let currentMin = currentData["minSpeedKmH"] as? Double,
                  let currentMax = currentData["maxSpeedKmH"] as? Double,
                  let currentCount = currentData["participantCount"] as? Int
            else {
                errorPointer?.pointee = NSError(
                    domain: "MetricsCollectorCycling",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing metrics fields on event doc"]
                )
                return nil
            }

            let newCount = currentCount + 1
            let newAvg = (currentAvg * Double(currentCount) + trimmedAvgSpeed) / Double(newCount)
            let newMin = min(currentMin, participantMinSpeed)
            let newMax = max(currentMax, participantMaxSpeed)

            transaction.updateData([
                "avgSpeedKmH": newAvg,
                "minSpeedKmH": newMin,
                "maxSpeedKmH": newMax,
                "participantCount": newCount
            ], forDocument: eventRef)

            return nil
        }

        logger.info("Cycling participant metrics uploaded and event averages updated")
    }

    // MARK: - Location config

    private func configureForCycling() {
        locationManager.applyConfiguration {
            $0.activityType = .automotiveNavigation
            $0.distanceFilter = 10
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
        guard isTracking,
              MetricsCollectorUtils.isValidLocation(location, lastLocation: lastLocation)
        else { return }

        trackedLocations.append((Date(), location))

        if let last = lastLocation {
            let delta = location.distance(from: last)
            totalDistanceMeters += delta
            distanceSinceLastSplit += delta

            let altDelta = location.altitude - last.altitude
            if altDelta > 0 { elevationGainMeters += altDelta }

            updateCurrentSpeed(from: location)
            checkSplit(at: location)
        }

        lastLocation = location
    }

    private func updateCurrentSpeed(from location: CLLocation) {
        guard location.speed > 0 else { return }
        currentSpeedKmH = location.speed * 3.6
        minSpeedKmH = min(minSpeedKmH, currentSpeedKmH)
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

        splits.append(SplitForCycling(number: splits.count + 1, paceInMinPerKm: 0, speedKmH: speedKmH))
        distanceSinceLastSplit = 0
        lastSplitDate = location.timestamp
    }

    private func reset() {
        trackedLocations = []
        totalDistanceMeters = 0
        currentSpeedKmH = 0
        averageSpeedKmH = 0
        elevationGainMeters = 0
        splits = []
        elapsedSeconds = 0
        lastLocation = nil
        distanceSinceLastSplit = 0
        lastSplitDate = nil
        minSpeedKmH = .infinity
        maxSpeedKmH = -.infinity
    }
}
