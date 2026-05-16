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

@Observable
class MetricsCollectorRun: MetricsCollector {

    // MARK: - Public state
    var trackedLocations: [CLLocation] = []
    var totalDistanceMeters: Double = 0
    var splits: [Split] = []
    var currentPaceMinPerKm: Double = 0
    var averagePaceMinPerKm: Double = 0
    var elapsedSeconds: Double = 0
    var isTracking = false

    // MARK: - Private
    private let locationManager = LocationManager.shared
    private let clLocationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var startDate: Date?
    private var timer: Timer?
    private var distanceSinceLastSplit: Double = 0
    private var lastSplitDate: Date?
    private var cancellables = Set<AnyCancellable>()

    private let splitEveryMeters: Double = 1000
    
    private let logger = Logger(subsystem: "sbud", category: "MetricsCollectorRun")
    init() {
        
        locationManager.$lastLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.handleNewLocation(location)
            }
            .store(in: &cancellables)
    }

    // MARK: - Control

    func startRun() {
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

    func stopRun() {
        restoreDefaultConfig()
        locationManager.stopUpdating()
        timer?.invalidate()
        timer = nil
        isTracking = false
    }

    // MARK: - Run-specific CLLocationManager config (not LocationManager's concern)

    private func configureForRun() {
        locationManager.applyConfiguration {
            $0.activityType = .fitness
            $0.distanceFilter = 5
            $0.pausesLocationUpdatesAutomatically = false

            // Only enable background updates if we have Always authorization
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

    // MARK: - Private logic

    private func handleNewLocation(_ location: CLLocation) {
        guard isTracking, isValid(location) else { return }

        trackedLocations.append(location)

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
