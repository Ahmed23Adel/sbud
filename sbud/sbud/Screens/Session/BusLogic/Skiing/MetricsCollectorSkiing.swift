//
//  MetricsCollectorSkiing.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import Foundation
import CoreLocation
import Combine
import HealthKit
import OSLog
import FirebaseFirestore

struct SplitForSkiing: Identifiable, Codable {
    var id = UUID()
    let number: Int
    let speedKmH: Double
    let dateTimeCreated = Date()
}

@Observable
class MetricsCollectorSkiing: MetricsCollector, MetricsCollectorTimeable, MetricsCollectorPersistable {

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
    private let locationManager: SessionLocationManaging
    private let healthKit: HealthKitServing
    private let userIdProvider: () -> String?
    private var lastLocation: CLLocation?
    private var startDate: Date?
    private var timer: Timer?
    private var checkpointTimer: Timer?
    private var distanceSinceLastSplit: Double = 0
    private var lastSplitDate: Date?
    private var isDescending = false
    private var currentEventId: String?
    private var cancellables = Set<AnyCancellable>()
    private let splitEveryMeters: Double = 1000
    private let checkpointIntervalSeconds: Double = 30
    let isCreator: Bool
    private let numSessions: Int
    private let logger = Logger(subsystem: "sbud", category: "MetricsCollectorSkiing")

    init(
        isCreator: Bool,
        numSessions: Int,
        locationManager: SessionLocationManaging = LocationManager.shared,
        healthKit: HealthKitServing = HealthKitService.shared,
        userIdProvider: @escaping () -> String? = { ProfileManager.shared.getLocalProfile()?.id }
    ) {
        self.isCreator = isCreator
        self.numSessions = numSessions
        self.locationManager = locationManager
        self.healthKit = healthKit
        self.userIdProvider = userIdProvider
        locationManager.lastLocationPublisher
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.handleNewLocation(location)
            }
            .store(in: &cancellables)
    }

    // MARK: - Control

    func startSession(eventId: String) {
        Task { await healthKit.requestAuthorization() }
        currentEventId = eventId

        if restoreCheckpoint(eventId: eventId) {
            logger.info("Restored crash checkpoint for eventId: \(eventId)")
        } else {
            logger.info("No checkpoint found, starting fresh")
            reset()
            startDate = Date()
            lastSplitDate = Date()
        }

        configureForSkiing()
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

        guard let userId = userIdProvider() else {
            throw MetricsError.profileNotAvailable
        }

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

        let snapshot = SkiingSessionSnapshot(
            eventId: eventId,
            startDate: startDate,
            lastSplitDate: lastSplitDate,
            totalDistanceMeters: totalDistanceMeters,
            distanceSinceLastSplit: distanceSinceLastSplit,
            elevationGainMeters: elevationGainMeters,
            verticalDropMeters: verticalDropMeters,
            numberOfRuns: numberOfRuns,
            isDescending: isDescending,
            elapsedSeconds: elapsedSeconds,
            maxSpeedKmH: maxSpeedKmH,
            splits: splits,
            trackPoints: trackedLocations.toTrackPoints()
        )

        let encoder = JSONEncoder()
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "inf", negativeInfinity: "-inf", nan: "nan"
        )
        guard let data = try? encoder.encode(snapshot) else {
            logger.error("Failed to encode SkiingSessionSnapshot")
            return
        }

        UserDefaults.standard.set(data, forKey: checkpointKey(eventId: eventId))
        logger.info("Checkpoint saved for eventId: \(eventId), \(self.trackedLocations.count) points")
    }

    func restoreCheckpoint(eventId: String) -> Bool {
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "inf", negativeInfinity: "-inf", nan: "nan"
        )
        guard let data = UserDefaults.standard.data(forKey: checkpointKey(eventId: eventId)),
              let snapshot = try? decoder.decode(SkiingSessionSnapshot.self, from: data)
        else { return false }

        startDate = snapshot.startDate
        lastSplitDate = snapshot.lastSplitDate
        totalDistanceMeters = snapshot.totalDistanceMeters
        distanceSinceLastSplit = snapshot.distanceSinceLastSplit
        elevationGainMeters = snapshot.elevationGainMeters
        verticalDropMeters = snapshot.verticalDropMeters
        numberOfRuns = snapshot.numberOfRuns
        isDescending = snapshot.isDescending
        elapsedSeconds = snapshot.elapsedSeconds
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

        let metrics = MetricsCollectedSkiing(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            metricsCreatorType: .creator,
            track: trackedLocations.toTrackPoints(),
            totalDistance: totalDistanceMeters,
            verticalDrop: verticalDropMeters,
            elevationGain: elevationGainMeters,
            numberOfRuns: numberOfRuns,
            splits: splits,
            numSession: numSessions
        )

        try await metrics.upload(eventId: eventId, userId: userId)
        try? await healthKit.saveGPSWorkout(
            activityType: .downhillSkiing,
            start: startDateTime,
            end: endDateTime,
            distanceMeters: totalDistanceMeters,
            locations: trackedLocations.map { $0.1 }
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
        guard let finalEndDateTime = try await MetricsCollectorUtils.readFinalEndDateTime(eventId: eventId) else {
            logger.info("Skiing participant ended before creator — storing data only")
            let endNow = Date()
            let metrics = MetricsCollectedSkiing(
                startDateTime: startDateTime,
                endDateTime: endNow,
                metricsCreatorType: .normalParticipant,
                track: trackedLocations.toTrackPoints(),
                totalDistance: totalDistanceMeters,
                verticalDrop: verticalDropMeters,
                elevationGain: elevationGainMeters,
                numberOfRuns: numberOfRuns,
                splits: splits,
                endedBeforeCreator: true,
                numSession: numSessions
            )
            try await metrics.upload(eventId: eventId, userId: userId)
            try? await healthKit.saveGPSWorkout(
                activityType: .downhillSkiing,
                start: startDateTime,
                end: endNow,
                distanceMeters: totalDistanceMeters,
                locations: trackedLocations.map { $0.1 }
            )
            return
        }

        let trimmedTrack = MetricsCollectorUtils.trimTrack(trackedLocations, to: finalEndDateTime)
        let trimmedSplits = splits.filter { $0.dateTimeCreated <= finalEndDateTime }
        let trimmedLocations = trimmedTrack.map { $0.1 }
        let trimmedDistance = MetricsCollectorUtils.computeDistance(from: trimmedLocations)
        let trimmedVerticalDrop = MetricsCollectorUtils.computeVerticalDrop(from: trimmedLocations)
        let trimmedElevationGain = MetricsCollectorUtils.computeElevationGain(from: trimmedLocations)
        let trimmedRuns = MetricsCollectorUtils.computeNumberOfRuns(from: trimmedLocations)

        let metrics = MetricsCollectedSkiing(
            startDateTime: startDateTime,
            endDateTime: finalEndDateTime,
            metricsCreatorType: .normalParticipant,
            track: trimmedTrack.toTrackPoints(),
            totalDistance: trimmedDistance,
            verticalDrop: trimmedVerticalDrop,
            elevationGain: trimmedElevationGain,
            numberOfRuns: trimmedRuns,
            splits: trimmedSplits,
            endedBeforeCreator: false,
            numSession: numSessions
        )
        try await metrics.upload(eventId: eventId, userId: userId)
        try? await healthKit.saveGPSWorkout(
            activityType: .downhillSkiing,
            start: startDateTime,
            end: finalEndDateTime,
            distanceMeters: trimmedDistance,
            locations: trimmedTrack.map { $0.1 }
        )
        logger.info("Skiing participant metrics uploaded")
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
        guard isTracking,
              MetricsCollectorUtils.isValidLocation(location, lastLocation: lastLocation)
        else { return }

        trackedLocations.append((Date(), location))

        if let last = lastLocation {
            let delta = location.distance(from: last)
            totalDistanceMeters += delta
            distanceSinceLastSplit += delta

            let altDelta = location.altitude - last.altitude
            if altDelta < 0 {
                verticalDropMeters += abs(altDelta)
                if !isDescending {
                    isDescending = true
                    numberOfRuns += 1
                }
            } else if altDelta > 0 {
                elevationGainMeters += altDelta
                isDescending = false
            }

            updateCurrentSpeed(from: location)
            checkSplit(at: location)
        }

        lastLocation = location
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
