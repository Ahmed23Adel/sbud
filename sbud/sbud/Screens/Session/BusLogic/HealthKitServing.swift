//
//  HealthKitServing.swift
//  sbud
//

import HealthKit
import CoreLocation

protocol HealthKitServing {
    func requestAuthorization() async
    func saveGPSWorkout(
        activityType: HKWorkoutActivityType,
        start: Date,
        end: Date,
        distanceMeters: Double,
        locations: [CLLocation]
    ) async throws
    func saveTimeBasedWorkout(
        activityType: HKWorkoutActivityType,
        start: Date,
        end: Date
    ) async throws
}

extension HealthKitService: HealthKitServing {}
