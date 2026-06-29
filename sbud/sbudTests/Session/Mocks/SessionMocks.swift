//
//  SessionMocks.swift
//  sbudTests
//

import Foundation
import CoreLocation
import Combine
import HealthKit
@testable import sbud

// MARK: - MockSessionLocationManager

final class MockSessionLocationManager: SessionLocationManaging {

    private let subject = PassthroughSubject<CLLocation?, Never>()
    var lastLocationPublisher: AnyPublisher<CLLocation?, Never> {
        subject.eraseToAnyPublisher()
    }

    var startUpdatingCallCount = 0
    var stopUpdatingCallCount = 0
    var configureCallCount = 0

    func startUpdating() { startUpdatingCallCount += 1 }
    func stopUpdating()  { stopUpdatingCallCount += 1 }
    func applyConfiguration(_ configure: (CLLocationManager) -> Void) {
        configureCallCount += 1
        // No-op: tests don't need real CLLocationManager config
    }

    func emit(_ location: CLLocation) {
        subject.send(location)
    }
}

// MARK: - MockHealthKitService

enum MockError: Error { case failed }

final class MockHealthKitService: HealthKitServing {

    var requestAuthorizationCallCount = 0
    var gpsWorkouts: [(activityType: HKWorkoutActivityType, start: Date, end: Date, distance: Double)] = []
    var timeBasedWorkouts: [(activityType: HKWorkoutActivityType, start: Date, end: Date)] = []
    var shouldThrowOnGPS = false
    var shouldThrowOnTimeBased = false

    func requestAuthorization() async {
        requestAuthorizationCallCount += 1
    }

    func saveGPSWorkout(
        activityType: HKWorkoutActivityType,
        start: Date,
        end: Date,
        distanceMeters: Double,
        locations: [CLLocation]
    ) async throws {
        if shouldThrowOnGPS { throw MockError.failed }
        gpsWorkouts.append((activityType, start, end, distanceMeters))
    }

    func saveTimeBasedWorkout(
        activityType: HKWorkoutActivityType,
        start: Date,
        end: Date
    ) async throws {
        if shouldThrowOnTimeBased { throw MockError.failed }
        timeBasedWorkouts.append((activityType, start, end))
    }
}

// MARK: - MockNetworkMonitor

final class MockNetworkMonitor: NetworkMonitoring {
    var isConnected: Bool
    private var onChange: ((Bool) -> Void)?

    init(isConnected: Bool = true) {
        self.isConnected = isConnected
    }

    func startMonitoring(onChange: @escaping (Bool) -> Void) {
        self.onChange = onChange
    }

    func stopMonitoring() {
        onChange = nil
    }

    func simulateConnectivityChange(connected: Bool) {
        isConnected = connected
        onChange?(connected)
    }
}

// MARK: - CLLocation helpers

extension CLLocation {
    static func make(
        lat: Double = 45.464664,
        lon: Double = 9.188540,
        altitude: Double = 0,
        accuracy: Double = 10,
        speed: Double = 5,
        timestamp: Date = Date()
    ) -> CLLocation {
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            altitude: altitude,
            horizontalAccuracy: accuracy,
            verticalAccuracy: 5,
            course: 0,
            speed: speed,
            timestamp: timestamp
        )
    }
}

// MARK: - Date helpers

extension Date {
    static func seconds(_ s: TimeInterval) -> Date {
        Date(timeIntervalSinceReferenceDate: s)
    }
}
