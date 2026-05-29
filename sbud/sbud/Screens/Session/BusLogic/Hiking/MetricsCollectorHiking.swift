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
class MetricsCollectorHiking: MetricsCollector, MetricsCollectorTimeable, MetricsCollectorPersistable {

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
    private var checkpointTimer: Timer?
    private var distanceSinceLastSplit: Double = 0
    private var lastSplitDate: Date?
    private var currentEventId: String?
    private var cancellables = Set<AnyCancellable>()
    private let splitEveryMeters: Double = 1000
    private let checkpointIntervalSeconds: Double = 30
    let isCreator: Bool
    private let numSessions: Int
    private let logger = Logger(subsystem: "sbud", category: "MetricsCollectorHiking")

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

        configureForHiking()
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

        let snapshot = HikingSessionSnapshot(
            eventId: eventId,
            startDate: startDate,
            lastSplitDate: lastSplitDate,
            totalDistanceMeters: totalDistanceMeters,
            distanceSinceLastSplit: distanceSinceLastSplit,
            elevationGainMeters: elevationGainMeters,
            elevationLossMeters: elevationLossMeters,
            maxAltitudeMeters: maxAltitudeMeters,
            currentAltitudeMeters: currentAltitudeMeters,
            elapsedSeconds: elapsedSeconds,
            splits: splits,
            trackPoints: trackedLocations.toTrackPoints()
        )

        guard let data = try? JSONEncoder().encode(snapshot) else {
            logger.error("Failed to encode HikingSessionSnapshot")
            return
        }

        UserDefaults.standard.set(data, forKey: checkpointKey(eventId: eventId))
        logger.info("Checkpoint saved for eventId: \(eventId), \(self.trackedLocations.count) points")
    }

    func restoreCheckpoint(eventId: String) -> Bool {
        guard let data = UserDefaults.standard.data(forKey: checkpointKey(eventId: eventId)),
              let snapshot = try? JSONDecoder().decode(HikingSessionSnapshot.self, from: data)
        else { return false }

        startDate = snapshot.startDate
        lastSplitDate = snapshot.lastSplitDate
        totalDistanceMeters = snapshot.totalDistanceMeters
        distanceSinceLastSplit = snapshot.distanceSinceLastSplit
        elevationGainMeters = snapshot.elevationGainMeters
        elevationLossMeters = snapshot.elevationLossMeters
        maxAltitudeMeters = snapshot.maxAltitudeMeters
        currentAltitudeMeters = snapshot.currentAltitudeMeters
        elapsedSeconds = snapshot.elapsedSeconds
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

        let metrics = MetricsCollectedHiking(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            metricsCreatorType: .creator,
            track: trackedLocations.toTrackPoints(),
            totalDistance: totalDistanceMeters,
            elevationGain: elevationGainMeters,
            elevationLoss: elevationLossMeters,
            maxAltitude: maxAltitudeMeters == -.infinity ? 0 : maxAltitudeMeters,
            splits: splits,
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
            logger.info("Hiking participant ended before creator — storing data only")
            let metrics = MetricsCollectedHiking(
                startDateTime: startDateTime,
                endDateTime: Date(),
                metricsCreatorType: .normalParticipant,
                track: trackedLocations.toTrackPoints(),
                totalDistance: totalDistanceMeters,
                elevationGain: elevationGainMeters,
                elevationLoss: elevationLossMeters,
                maxAltitude: maxAltitudeMeters == -.infinity ? 0 : maxAltitudeMeters,
                splits: splits,
                endedBeforeCreator: true,
                numSession: numSessions
            )
            try await metrics.upload(eventId: eventId, userId: userId)
            return
        }

        let trimmedTrack = MetricsCollectorUtils.trimTrack(trackedLocations, to: finalEndDateTime)
        let trimmedSplits = splits.filter { $0.dateTimeCreated <= finalEndDateTime }
        let trimmedLocations = trimmedTrack.map { $0.1 }
        let trimmedDistance = MetricsCollectorUtils.computeDistance(from: trimmedLocations)
        let trimmedElevationGain = MetricsCollectorUtils.computeElevationGain(from: trimmedLocations)
        let trimmedElevationLoss = MetricsCollectorUtils.computeElevationLoss(from: trimmedLocations)
        let trimmedMaxAltitude = trimmedLocations.map(\.altitude).max() ?? 0

        let metrics = MetricsCollectedHiking(
            startDateTime: startDateTime,
            endDateTime: finalEndDateTime,
            metricsCreatorType: .normalParticipant,
            track: trimmedTrack.toTrackPoints(),
            totalDistance: trimmedDistance,
            elevationGain: trimmedElevationGain,
            elevationLoss: trimmedElevationLoss,
            maxAltitude: trimmedMaxAltitude,
            splits: trimmedSplits,
            endedBeforeCreator: false,
            numSession: numSessions
        )
        try await metrics.upload(eventId: eventId, userId: userId)
        logger.info("Hiking participant metrics uploaded")
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
        guard isTracking,
              MetricsCollectorUtils.isValidLocation(location, lastLocation: lastLocation)
        else { return }

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
