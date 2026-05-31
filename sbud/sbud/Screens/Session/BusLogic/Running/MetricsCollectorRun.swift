//
//  MetricsCollectorRun.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

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
//
//  MetricsCollectorRun.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import Foundation
import CoreLocation
import Combine
import HealthKit
import OSLog
import FirebaseFirestore

struct TrackPoint: Codable {
    let timestamp: Date
    let latitude: Double
    let longitude: Double
}

enum MetricsCreatorType: String, Codable {
    case creator = "Creator"
    case normalParticipant = "Normal Participant"
}

@Observable
class MetricsCollectorRun: MetricsCollector, MetricsCollectorTimeable, MetricsCollectorPersistable {

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
    private var checkpointTimer: Timer?
    private var distanceSinceLastSplit: Double = 0
    private var lastSplitDate: Date?
    private var currentEventId: String?
    private var cancellables = Set<AnyCancellable>()
    private let splitEveryMeters: Double = 1000
    private let checkpointIntervalSeconds: Double = 30
    let isCreator: Bool
    private let numSessions: Int
    private let logger = Logger(subsystem: "sbud", category: "MetricsCollectorRun")

    init(isCreator: Bool, numSessions: Int) {
        self.numSessions = numSessions
        self.isCreator = isCreator
        locationManager.$lastLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.handleNewLocation(location)
            }
            .store(in: &cancellables)
    }

    // MARK: - Control

    func startSession(eventId: String) {
        Task { await HealthKitService.shared.requestAuthorization() }
        currentEventId = eventId

        if restoreCheckpoint(eventId: eventId) {
            logger.info("Restored crash checkpoint for eventId: \(eventId)")
        } else {
            logger.info("No checkpoint found, starting fresh")
            reset()
            startDate = Date()
            lastSplitDate = Date()
        }

        configureForRun()
        locationManager.startUpdating()
        isTracking = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startDate else { return }
            self.elapsedSeconds = Date().timeIntervalSince(start)
            self.updateAveragePace()
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

        let snapshot = RunSessionSnapshot(
            eventId: eventId,
            startDate: startDate,
            lastSplitDate: lastSplitDate,
            totalDistanceMeters: totalDistanceMeters,
            distanceSinceLastSplit: distanceSinceLastSplit,
            elapsedSeconds: elapsedSeconds,
            minPace: minPace,
            maxPace: maxPace,
            splits: splits,
            trackPoints: trackedLocations.toTrackPoints()
        )

        guard let data = try? JSONEncoder().encode(snapshot) else {
            logger.error("Failed to encode RunSessionSnapshot")
            return
        }

        UserDefaults.standard.set(data, forKey: checkpointKey(eventId: eventId))
        logger.info("Checkpoint saved for eventId: \(eventId), \(self.trackedLocations.count) points")
    }

    func restoreCheckpoint(eventId: String) -> Bool {
        guard let data = UserDefaults.standard.data(forKey: checkpointKey(eventId: eventId)),
              let snapshot = try? JSONDecoder().decode(RunSessionSnapshot.self, from: data)
        else { return false }

        startDate = snapshot.startDate
        lastSplitDate = snapshot.lastSplitDate
        totalDistanceMeters = snapshot.totalDistanceMeters
        distanceSinceLastSplit = snapshot.distanceSinceLastSplit
        elapsedSeconds = snapshot.elapsedSeconds
        minPace = snapshot.minPace
        maxPace = snapshot.maxPace
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

        let metrics = MetricsCollectedRun(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            metricsCreatorType: .creator,
            track: trackedLocations.toTrackPoints(),
            totalDistance: totalDistanceMeters,
            splits: splits,
            numSession: numSessions
        )

        try await metrics.upload(eventId: eventId, userId: userId)
        try? await HealthKitService.shared.saveGPSWorkout(
            activityType: .running,
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
            logger.info("Participant ended before creator — storing data only")
            let endNow = Date()
            let metrics = MetricsCollectedRun(
                startDateTime: startDateTime,
                endDateTime: endNow,
                metricsCreatorType: .normalParticipant,
                track: trackedLocations.toTrackPoints(),
                totalDistance: totalDistanceMeters,
                splits: splits,
                endedBeforeCreator: true,
                numSession: numSessions
            )
            try await metrics.upload(eventId: eventId, userId: userId)
            try? await HealthKitService.shared.saveGPSWorkout(
                activityType: .running,
                start: startDateTime,
                end: endNow,
                distanceMeters: totalDistanceMeters,
                locations: trackedLocations.map { $0.1 }
            )
            return
        }

        let trimmedTrack = MetricsCollectorUtils.trimTrack(trackedLocations, to: finalEndDateTime)
        let trimmedSplits = splits.filter { $0.dateTimeCreated <= finalEndDateTime }
        let trimmedDistance = MetricsCollectorUtils.computeDistance(from: trimmedTrack.map { $0.1 })

        let metrics = MetricsCollectedRun(
            startDateTime: startDateTime,
            endDateTime: finalEndDateTime,
            metricsCreatorType: .normalParticipant,
            track: trimmedTrack.toTrackPoints(),
            totalDistance: trimmedDistance,
            splits: trimmedSplits,
            endedBeforeCreator: false,
            numSession: numSessions
        )
        try await metrics.upload(eventId: eventId, userId: userId)
        try? await HealthKitService.shared.saveGPSWorkout(
            activityType: .running,
            start: startDateTime,
            end: finalEndDateTime,
            distanceMeters: trimmedDistance,
            locations: trimmedTrack.map { $0.1 }
        )
        logger.info("Participant metrics uploaded")
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
        guard isTracking,
              MetricsCollectorUtils.isValidLocation(location, lastLocation: lastLocation)
        else { return }

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
        minPace = .infinity
        maxPace = -.infinity
    }
}
