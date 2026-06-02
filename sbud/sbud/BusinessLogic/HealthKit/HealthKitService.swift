//
//  HealthKitService.swift
//  sbud
//

import HealthKit
import CoreLocation

final class HealthKitService {
    static let shared = HealthKitService()
    private let store = HKHealthStore()

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let types: Set<HKSampleType> = [
            HKWorkoutType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.distanceCycling),
        ]
        try? await store.requestAuthorization(toShare: types, read: [])
    }

    // MARK: - GPS sports (Running, Cycling, Hiking, Skiing)

    /// Saves a workout with GPS route to HealthKit.
    /// - Parameter locations: raw `CLLocation` array from the collector's `trackedLocations`
    func saveGPSWorkout(
        activityType: HKWorkoutActivityType,
        start: Date,
        end: Date,
        distanceMeters: Double,
        locations: [CLLocation]
    ) async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let config = HKWorkoutConfiguration()
        config.activityType = activityType
        config.locationType = .outdoor

        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())
        try await builder.beginCollection(at: start) //  marks the start timestamp, opens the transaction

        if distanceMeters > 0 {
            let quantityType: HKQuantityType = activityType == .cycling
                ? HKQuantityType(.distanceCycling)
                : HKQuantityType(.distanceWalkingRunning)

            let sample = HKQuantitySample(
                type: quantityType,
                quantity: HKQuantity(unit: .meter(), doubleValue: distanceMeters),
                start: start,
                end: end
            )
            try await builder.addSamples([sample])
        }

        try await builder.endCollection(at: end)
        let workout = try await builder.finishWorkout() // commits everything to the HealthKit database and returns the saved HKWorkout object

        guard !locations.isEmpty, let workout else { return }
        let routeBuilder = HKWorkoutRouteBuilder(healthStore: store, device: nil)
        try await routeBuilder.insertRouteData(locations)
        // save it seperatly and link them
        try await routeBuilder.finishRoute(with: workout, metadata: nil)
    }

    // MARK: - Time-based sports (Gym, Swimming, Tennis, Yoga)

    func saveTimeBasedWorkout(
        activityType: HKWorkoutActivityType,
        start: Date,
        end: Date
    ) async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let config = HKWorkoutConfiguration()
        config.activityType = activityType
        config.locationType = .outdoor

        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())
        try await builder.beginCollection(at: start)
        try await builder.endCollection(at: end)
        _ = try await builder.finishWorkout()
    }
}
