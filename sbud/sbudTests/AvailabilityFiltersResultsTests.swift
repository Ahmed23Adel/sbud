//
//  AvailabilityFiltersResultsTests.swift
//  sbudTests
//
//  Created by ahmed on 06/05/2026.
//

import Foundation

//
//  Comprehensive unit-test suite for the Filters module.
//  Covers:
//    • AvailabilityConfig
//    • ActivityType
//    • GymDayType / GenderFilter / enum raw values
//    • ExtraArgsFilterHolder* (filter state holders)
//    • ExtraArgsHolder* (event arg holders) — init, encode/decode, areFieldsValid
//    • ExtraArgsHolder (polymorphic container) — decode dispatch, updateExtraArgs
//    • AvailabilityFiltersResults — default state, buildSearchPayload, buildExtraQueryParams
//    • FiltersViewModel — selectedActivityIndex sync, selectedActivityType
//

import XCTest
import Combine
internal import SwiftUI
@testable import sbud

// MARK: - Helpers

private func encode<T: Encodable>(_ value: T) throws -> Data {
    try JSONEncoder().encode(value)
}

private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    try JSONDecoder().decode(type, from: data)
}

// Round-trip helper: encode then decode
private func roundTrip<T: Codable>(_ value: T) throws -> T {
    try decode(T.self, from: encode(value))
}

// MARK: - AvailabilityConfig Tests

final class AvailabilityConfigTests: XCTestCase {

    func test_icons_count_matches_activityNames() {
        XCTAssertEqual(AvailabilityConfig.icons.count, AvailabilityConfig.activityNames.count)
    }

    func test_activityType_allIndices() {
        let expected: [ActivityType] = [
            .running, .cycling, .gym, .skiing,
            .swimming, .hiking, .yoga, .tennis
        ]
        for (index, expected) in expected.enumerated() {
            XCTAssertEqual(AvailabilityConfig.activityType(for: index), expected,
                           "Index \(index) should map to \(expected)")
        }
    }

    func test_activityType_outOfBounds_returnsRunning() {
        XCTAssertEqual(AvailabilityConfig.activityType(for: 99), .running)
        XCTAssertEqual(AvailabilityConfig.activityType(for: -1), .running)
    }

    func test_activityNames_correctValues() {
        XCTAssertEqual(AvailabilityConfig.activityNames[0], "Running")
        XCTAssertEqual(AvailabilityConfig.activityNames[2], "Gym")
        XCTAssertEqual(AvailabilityConfig.activityNames[7], "Tennis")
    }

    func test_icons_areNotEmpty() {
        for icon in AvailabilityConfig.icons {
            XCTAssertFalse(icon.isEmpty)
        }
    }
}



// MARK: - GymDayType Tests

final class GymDayTypeTests: XCTestCase {

    func test_allCases_count() {
        XCTAssertEqual(GymDayType.allCases.count, 8)
    }

    func test_rawValues() {
        XCTAssertEqual(GymDayType.push.rawValue,     "Push")
        XCTAssertEqual(GymDayType.pull.rawValue,     "Pull")
        XCTAssertEqual(GymDayType.leg.rawValue,      "Leg")
        XCTAssertEqual(GymDayType.arm.rawValue,      "Arm")
        XCTAssertEqual(GymDayType.upper.rawValue,    "Upper")
        XCTAssertEqual(GymDayType.lower.rawValue,    "Lower")
        XCTAssertEqual(GymDayType.fullBody.rawValue, "Full Body")
        XCTAssertEqual(GymDayType.core.rawValue,     "Core")
    }

    func test_codable_roundTrip() throws {
        for day in GymDayType.allCases {
            let decoded = try roundTrip(day)
            XCTAssertEqual(decoded, day)
        }
    }
}

// MARK: - GenderFilter Tests

final class GenderFilterTests: XCTestCase {

    func test_allCases_count() {
        XCTAssertEqual(GenderFilter.allCases.count, 3)
    }

    func test_rawValues() {
        XCTAssertEqual(GenderFilter.any.rawValue,    "Any")
        XCTAssertEqual(GenderFilter.male.rawValue,   "Male")
        XCTAssertEqual(GenderFilter.female.rawValue, "Female")
    }

    func test_codable_roundTrip() throws {
        for gender in GenderFilter.allCases {
            let decoded = try roundTrip(gender)
            XCTAssertEqual(decoded, gender)
        }
    }
}

// MARK: - Sport-specific enum Tests

final class SportEnumTests: XCTestCase {

    // RunningType
    func test_runningType_rawValues() {
        XCTAssertEqual(RunningType.road.rawValue,      "Road")
        XCTAssertEqual(RunningType.trail.rawValue,     "Trail")
        XCTAssertEqual(RunningType.track.rawValue,     "Track")
        XCTAssertEqual(RunningType.treadmill.rawValue, "Treadmill")
    }

    // CyclingType
    func test_cyclingType_rawValues() {
        XCTAssertEqual(CyclingType.street.rawValue,   "Street")
        XCTAssertEqual(CyclingType.track.rawValue,    "Track")
        XCTAssertEqual(CyclingType.mountain.rawValue, "Mountain")
        XCTAssertEqual(CyclingType.downhill.rawValue, "Downhill mountain")
    }

    // SwimmingStroke
    func test_swimmingStroke_allCases() {
        XCTAssertEqual(SwimmingStroke.allCases.count, 5)
        XCTAssertEqual(SwimmingStroke.freestyle.rawValue,    "Freestyle")
        XCTAssertEqual(SwimmingStroke.breaststroke.rawValue, "Breaststroke")
        XCTAssertEqual(SwimmingStroke.backstroke.rawValue,   "Backstroke")
        XCTAssertEqual(SwimmingStroke.butterfly.rawValue,    "Butterfly")
        XCTAssertEqual(SwimmingStroke.medley.rawValue,       "Medley")
    }

    // YogaStyle
    func test_yogaStyle_allCases() {
        XCTAssertEqual(YogaStyle.allCases.count, 6)
        XCTAssertEqual(YogaStyle.vinyasa.rawValue,     "Vinyasa")
        XCTAssertEqual(YogaStyle.hatha.rawValue,       "Hatha")
        XCTAssertEqual(YogaStyle.ashtanga.rawValue,    "Ashtanga")
        XCTAssertEqual(YogaStyle.yin.rawValue,         "Yin")
        XCTAssertEqual(YogaStyle.restorative.rawValue, "Restorative")
        XCTAssertEqual(YogaStyle.power.rawValue,       "Power")
    }

    // TennisFormat
    func test_tennisFormat_allCases() {
        XCTAssertEqual(TennisFormat.allCases.count, 2)
        XCTAssertEqual(TennisFormat.singles.rawValue, "Singles")
        XCTAssertEqual(TennisFormat.doubles.rawValue, "Doubles")
    }
}

// MARK: - ExtraArgsFilterHolder Tests  (filter-search state holders)

final class ExtraArgsFilterHolderTests: XCTestCase {

    func test_running_defaultsAreNil() {
        let f = ExtraArgsFilterHolderRunning()
        XCTAssertNil(f.minDistance)
        XCTAssertNil(f.maxDistance)
        XCTAssertNil(f.minPace)
        XCTAssertNil(f.maxPace)
        XCTAssertNil(f.runningType)
    }

    func test_cycling_defaultsAreNil() {
        let f = ExtraArgsFilterHolderCycling()
        XCTAssertNil(f.minPower)
        XCTAssertNil(f.maxPower)
        XCTAssertNil(f.minCadence)
        XCTAssertNil(f.maxCadence)
        XCTAssertNil(f.cyclingType)
    }

    func test_gym_defaultIsNil() {
        XCTAssertNil(ExtraArgsFilterHolderGym().gymDayType)
    }

    func test_skiing_defaultsAreNil() {
        let f = ExtraArgsFilterHolderSkiing()
        XCTAssertNil(f.minSpeed)
        XCTAssertNil(f.maxSpeed)
        XCTAssertNil(f.minDrop)
        XCTAssertNil(f.maxDrop)
    }

    func test_swimming_defaultsAreNil() {
        let f = ExtraArgsFilterHolderSwimming()
        XCTAssertNil(f.minDistance)
        XCTAssertNil(f.maxDistance)
        XCTAssertNil(f.minPace)
        XCTAssertNil(f.maxPace)
        XCTAssertNil(f.stroke)
    }

    func test_hiking_defaultsAreNil() {
        let f = ExtraArgsFilterHolderHiking()
        XCTAssertNil(f.minDistance)
        XCTAssertNil(f.maxDistance)
        XCTAssertNil(f.minElevation)
        XCTAssertNil(f.maxElevation)
    }

    func test_yoga_defaultsAreNil() {
        let f = ExtraArgsFilterHolderYoga()
        XCTAssertNil(f.minDuration)
        XCTAssertNil(f.maxDuration)
        XCTAssertNil(f.minIntensity)
        XCTAssertNil(f.maxIntensity)
        XCTAssertNil(f.style)
    }

    func test_tennis_defaultsAreNil() {
        let f = ExtraArgsFilterHolderTennis()
        XCTAssertNil(f.minSets)
        XCTAssertNil(f.maxSets)
        XCTAssertNil(f.minDuration)
        XCTAssertNil(f.maxDuration)
        XCTAssertNil(f.format)
    }

    func test_running_canSetValues() {
        let f = ExtraArgsFilterHolderRunning()
        f.minDistance = 5.0
        f.maxDistance = 20.0
        f.minPace     = 4.0
        f.maxPace     = 7.0
        f.runningType = .trail
        XCTAssertEqual(f.minDistance, 5.0)
        XCTAssertEqual(f.maxDistance, 20.0)
        XCTAssertEqual(f.minPace,     4.0)
        XCTAssertEqual(f.maxPace,     7.0)
        XCTAssertEqual(f.runningType, .trail)
    }
}

// MARK: - ExtraArgsHolder (event args) — default values + areFieldsValid

final class ExtraArgsHolderDefaultTests: XCTestCase {

    func test_running_defaults() {
        let h = ExtraArgsHolderRunning()
        XCTAssertEqual(h.activityType, ActivityType.running.rawValue)
        XCTAssertEqual(h.proposedDistance, 6.0)
        XCTAssertEqual(h.proposedPace, 8.30)
        XCTAssertEqual(h.proposedRunningType, .road)
    }

    func test_cycling_defaults() {
        let h = ExtraArgsHolderCycling()
        XCTAssertEqual(h.activityType, ActivityType.cycling.rawValue)
        XCTAssertEqual(h.proposedPowerInWatt, 200.0)
        XCTAssertEqual(h.proposedCadenceInRPM, 80.0)
        XCTAssertEqual(h.proposedCyclingType, .street)
    }

    func test_gym_defaults() {
        let h = ExtraArgsHolderGym()
        XCTAssertEqual(h.activityType, ActivityType.gym.rawValue)
        XCTAssertEqual(h.proposedDayType, .push)
    }

    func test_skiing_defaults() {
        let h = ExtraArgsHolderSkiing()
        XCTAssertEqual(h.activityType, ActivityType.skiing.rawValue)
        XCTAssertEqual(h.proposedSpeedInKmH, 40.0)
        XCTAssertEqual(h.proposedVerticalDropInM, 500.0)
    }

    func test_swimming_defaults() {
        let h = ExtraArgsHolderSwimming()
        XCTAssertEqual(h.activityType, ActivityType.swimming.rawValue)
        XCTAssertEqual(h.proposedDistanceInM, 1000.0)
        XCTAssertEqual(h.proposedPacePer100M, 2.0)
        XCTAssertEqual(h.proposedStroke, .freestyle)
    }

    func test_hiking_defaults() {
        let h = ExtraArgsHolderHiking()
        XCTAssertEqual(h.activityType, ActivityType.hiking.rawValue)
        XCTAssertEqual(h.proposedDistanceInKm, 10.0)
        XCTAssertEqual(h.proposedElevationGainInM, 400.0)
    }

    func test_yoga_defaults() {
        let h = ExtraArgsHolderYoga()
        XCTAssertEqual(h.activityType, ActivityType.yoga.rawValue)
        XCTAssertEqual(h.proposedDurationInMin, 60.0)
        XCTAssertEqual(h.proposedIntensityLevel, 5.0)
        XCTAssertEqual(h.proposedStyle, .vinyasa)
    }

    func test_tennis_defaults() {
        let h = ExtraArgsHolderTennis()
        XCTAssertEqual(h.activityType, ActivityType.tennis.rawValue)
        XCTAssertEqual(h.proposedSets, 3.0)
        XCTAssertEqual(h.proposedDurationInMin, 90.0)
        XCTAssertEqual(h.proposedFormat, .singles)
    }
}

// MARK: - areFieldsValid

final class ExtraArgsHolderValidationTests: XCTestCase {

    // Running
    func test_running_valid_whenDistanceAndPacePositive() {
        let h = ExtraArgsHolderRunning()
        XCTAssertTrue(h.areFieldsValid())
    }

    func test_running_invalid_whenDistanceIsZero() {
        let h = ExtraArgsHolderRunning()
        h.proposedDistance = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_running_invalid_whenPaceIsZero() {
        let h = ExtraArgsHolderRunning()
        h.proposedPace = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_running_invalid_whenNegativeValues() {
        let h = ExtraArgsHolderRunning()
        h.proposedDistance = -1
        XCTAssertFalse(h.areFieldsValid())
    }

    // Cycling
    func test_cycling_valid_byDefault() {
        XCTAssertTrue(ExtraArgsHolderCycling().areFieldsValid())
    }

    func test_cycling_invalid_whenPowerIsZero() {
        let h = ExtraArgsHolderCycling()
        h.proposedPowerInWatt = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_cycling_invalid_whenCadenceIsZero() {
        let h = ExtraArgsHolderCycling()
        h.proposedCadenceInRPM = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    // Gym — always valid
    func test_gym_alwaysValid() {
        XCTAssertTrue(ExtraArgsHolderGym().areFieldsValid())
    }

    // Skiing
    func test_skiing_valid_byDefault() {
        XCTAssertTrue(ExtraArgsHolderSkiing().areFieldsValid())
    }

    func test_skiing_invalid_whenSpeedIsZero() {
        let h = ExtraArgsHolderSkiing()
        h.proposedSpeedInKmH = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_skiing_invalid_whenDropIsZero() {
        let h = ExtraArgsHolderSkiing()
        h.proposedVerticalDropInM = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    // Swimming
    func test_swimming_valid_byDefault() {
        XCTAssertTrue(ExtraArgsHolderSwimming().areFieldsValid())
    }

    func test_swimming_invalid_whenDistanceIsZero() {
        let h = ExtraArgsHolderSwimming()
        h.proposedDistanceInM = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_swimming_invalid_whenPaceIsZero() {
        let h = ExtraArgsHolderSwimming()
        h.proposedPacePer100M = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    // Hiking
    func test_hiking_valid_byDefault() {
        XCTAssertTrue(ExtraArgsHolderHiking().areFieldsValid())
    }

    func test_hiking_invalid_whenDistanceIsZero() {
        let h = ExtraArgsHolderHiking()
        h.proposedDistanceInKm = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_hiking_valid_whenElevationIsZero() {
        // elevation >= 0 is valid (flat hike)
        let h = ExtraArgsHolderHiking()
        h.proposedElevationGainInM = 0
        XCTAssertTrue(h.areFieldsValid())
    }

    func test_hiking_invalid_whenElevationIsNegative() {
        let h = ExtraArgsHolderHiking()
        h.proposedElevationGainInM = -1
        XCTAssertFalse(h.areFieldsValid())
    }

    // Yoga
    func test_yoga_valid_byDefault() {
        XCTAssertTrue(ExtraArgsHolderYoga().areFieldsValid())
    }

    func test_yoga_invalid_whenDurationIsZero() {
        let h = ExtraArgsHolderYoga()
        h.proposedDurationInMin = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_yoga_invalid_whenIntensityBelowOne() {
        let h = ExtraArgsHolderYoga()
        h.proposedIntensityLevel = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_yoga_invalid_whenIntensityAboveTen() {
        let h = ExtraArgsHolderYoga()
        h.proposedIntensityLevel = 11
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_yoga_valid_atBoundaryIntensity() {
        let h = ExtraArgsHolderYoga()
        h.proposedIntensityLevel = 1
        XCTAssertTrue(h.areFieldsValid())
        h.proposedIntensityLevel = 10
        XCTAssertTrue(h.areFieldsValid())
    }

    // Tennis
    func test_tennis_valid_byDefault() {
        XCTAssertTrue(ExtraArgsHolderTennis().areFieldsValid())
    }

    func test_tennis_invalid_whenSetsZero() {
        let h = ExtraArgsHolderTennis()
        h.proposedSets = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_tennis_invalid_whenSetsAboveThree() {
        let h = ExtraArgsHolderTennis()
        h.proposedSets = 4
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_tennis_valid_atBoundarySets() {
        let h = ExtraArgsHolderTennis()
        h.proposedSets = 1
        XCTAssertTrue(h.areFieldsValid())
        h.proposedSets = 3
        XCTAssertTrue(h.areFieldsValid())
    }

    func test_tennis_invalid_whenDurationIsZero() {
        let h = ExtraArgsHolderTennis()
        h.proposedDurationInMin = 0
        XCTAssertFalse(h.areFieldsValid())
    }
}

// MARK: - ExtraArgsHolder Codable Round-trip Tests

final class ExtraArgsHolderCodableTests: XCTestCase {

    func test_running_roundTrip() throws {
        let h = ExtraArgsHolderRunning()
        h.proposedDistance    = 12.5
        h.proposedPace        = 5.45
        h.proposedRunningType = .trail

        let data    = try encode(h)
        let decoded = try decode(ExtraArgsHolderRunning.self, from: data)

        XCTAssertEqual(decoded.proposedDistance,    12.5)
        XCTAssertEqual(decoded.proposedPace,        5.45)
        XCTAssertEqual(decoded.proposedRunningType, .trail)
        XCTAssertEqual(decoded.activityType,        ActivityType.running.rawValue)
    }

    func test_cycling_roundTrip() throws {
        let h = ExtraArgsHolderCycling()
        h.proposedCyclingType  = .mountain
        h.proposedPowerInWatt  = 250.0
        h.proposedCadenceInRPM = 95.0

        let decoded = try roundTrip(h)
        XCTAssertEqual(decoded.proposedCyclingType,  .mountain)
        XCTAssertEqual(decoded.proposedPowerInWatt,  250.0)
        XCTAssertEqual(decoded.proposedCadenceInRPM, 95.0)
    }

    func test_gym_roundTrip() throws {
        let h = ExtraArgsHolderGym()
        h.proposedDayType = .leg

        let decoded = try roundTrip(h)
        XCTAssertEqual(decoded.proposedDayType, .leg)
    }

    func test_skiing_roundTrip() throws {
        let h = ExtraArgsHolderSkiing()
        h.proposedSpeedInKmH       = 60.0
        h.proposedVerticalDropInM  = 800.0

        let decoded = try roundTrip(h)
        XCTAssertEqual(decoded.proposedSpeedInKmH,      60.0)
        XCTAssertEqual(decoded.proposedVerticalDropInM, 800.0)
    }

    func test_swimming_roundTrip() throws {
        let h = ExtraArgsHolderSwimming()
        h.proposedDistanceInM = 1500.0
        h.proposedPacePer100M = 1.45
        h.proposedStroke      = .butterfly

        let decoded = try roundTrip(h)
        XCTAssertEqual(decoded.proposedDistanceInM, 1500.0)
        XCTAssertEqual(decoded.proposedPacePer100M, 1.45)
        XCTAssertEqual(decoded.proposedStroke,      .butterfly)
    }

    func test_hiking_roundTrip() throws {
        let h = ExtraArgsHolderHiking()
        h.proposedDistanceInKm     = 25.0
        h.proposedElevationGainInM = 1200.0

        let decoded = try roundTrip(h)
        XCTAssertEqual(decoded.proposedDistanceInKm,     25.0)
        XCTAssertEqual(decoded.proposedElevationGainInM, 1200.0)
    }

    func test_yoga_roundTrip() throws {
        let h = ExtraArgsHolderYoga()
        h.proposedDurationInMin  = 90.0
        h.proposedIntensityLevel = 8.0
        h.proposedStyle          = .ashtanga

        let decoded = try roundTrip(h)
        XCTAssertEqual(decoded.proposedDurationInMin,  90.0)
        XCTAssertEqual(decoded.proposedIntensityLevel, 8.0)
        XCTAssertEqual(decoded.proposedStyle,          .ashtanga)
    }

    func test_tennis_roundTrip() throws {
        let h = ExtraArgsHolderTennis()
        h.proposedSets          = 2.0
        h.proposedDurationInMin = 75.0
        h.proposedFormat        = .doubles

        let decoded = try roundTrip(h)
        XCTAssertEqual(decoded.proposedSets,          2.0)
        XCTAssertEqual(decoded.proposedDurationInMin, 75.0)
        XCTAssertEqual(decoded.proposedFormat,        .doubles)
    }

    // Decoding with missing fields should fall back to defaults
    func test_running_decodesWithMissingFields_usesDefaults() throws {
        let json = #"{"activityType":"Running"}"#
        let data = json.data(using: .utf8)!
        let h = try decode(ExtraArgsHolderRunning.self, from: data)
        XCTAssertEqual(h.proposedDistance,    6.0)
        XCTAssertEqual(h.proposedPace,        8.30)
        XCTAssertEqual(h.proposedRunningType, .road)
    }

    func test_tennis_decodesWithMissingFields_usesDefaults() throws {
        let json = #"{"activityType":"Tennis"}"#
        let data = json.data(using: .utf8)!
        let h = try decode(ExtraArgsHolderTennis.self, from: data)
        XCTAssertEqual(h.proposedSets,          3.0)
        XCTAssertEqual(h.proposedDurationInMin, 90.0)
        XCTAssertEqual(h.proposedFormat,        .singles)
    }
}

// MARK: - ExtraArgsHolder (polymorphic container) Tests

final class ExtraArgsHolderContainerTests: XCTestCase {

    func test_default_isRunning() {
        let h = ExtraArgsHolder()
        XCTAssertEqual(h.selectedActivity, .running)
        XCTAssertTrue(h.extraArgs is ExtraArgsHolderRunning)
    }

    func test_updateExtraArgs_switchesToCorrectType() {
        let h = ExtraArgsHolder()
        let activities: [(ActivityType, Any.Type)] = [
            (.cycling,  ExtraArgsHolderCycling.self),
            (.gym,      ExtraArgsHolderGym.self),
            (.skiing,   ExtraArgsHolderSkiing.self),
            (.swimming, ExtraArgsHolderSwimming.self),
            (.hiking,   ExtraArgsHolderHiking.self),
            (.yoga,     ExtraArgsHolderYoga.self),
            (.tennis,   ExtraArgsHolderTennis.self),
            (.running,  ExtraArgsHolderRunning.self),
        ]
        for (activity, expectedType) in activities {
            h.selectedActivity = activity
            XCTAssertTrue(
                type(of: h.extraArgs) == expectedType,
                "Expected \(expectedType) for \(activity) but got \(type(of: h.extraArgs))"
            )
        }
    }

    func test_areFieldsValid_delegatesToExtraArgs() {
        let h = ExtraArgsHolder()
        XCTAssertTrue(h.areFieldsValid())
        (h.extraArgs as? ExtraArgsHolderRunning)?.proposedDistance = 0
        XCTAssertFalse(h.areFieldsValid())
    }

    func test_decode_cycling_dispatchesCorrectly() throws {
        let json = """
        {
            "activityType": "Cycling",
            "proposedCyclingType": "Mountain",
            "proposedPowerInWatt": 300.0,
            "proposedCadenceInRPM": 90.0
        }
        """
        let data = json.data(using: .utf8)!
        let h    = try decode(ExtraArgsHolder.self, from: data)
        XCTAssertEqual(h.selectedActivity, .cycling)
        let cyclingArgs = try XCTUnwrap(h.extraArgs as? ExtraArgsHolderCycling)
        XCTAssertEqual(cyclingArgs.proposedCyclingType,  .mountain)
        XCTAssertEqual(cyclingArgs.proposedPowerInWatt,  300.0)
        XCTAssertEqual(cyclingArgs.proposedCadenceInRPM, 90.0)
    }

    func test_decode_yoga_dispatchesCorrectly() throws {
        let json = """
        {
            "activityType": "Yoga",
            "proposedDurationInMin": 45.0,
            "proposedIntensityLevel": 7.0,
            "proposedStyle": "Yin"
        }
        """
        let data = json.data(using: .utf8)!
        let h    = try decode(ExtraArgsHolder.self, from: data)
        XCTAssertEqual(h.selectedActivity, .yoga)
        let yogaArgs = try XCTUnwrap(h.extraArgs as? ExtraArgsHolderYoga)
        XCTAssertEqual(yogaArgs.proposedDurationInMin,  45.0)
        XCTAssertEqual(yogaArgs.proposedIntensityLevel, 7.0)
        XCTAssertEqual(yogaArgs.proposedStyle,          .yin)
    }

    func test_decode_unknownActivityType_throws() {
        let json = #"{"activityType":"Badminton"}"#
        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try decode(ExtraArgsHolder.self, from: data))
    }
}

// MARK: - AvailabilityFiltersResults Tests

final class AvailabilityFiltersResultsFullTests: XCTestCase {

    // MARK: Defaults

    func test_defaults() {
        let r = AvailabilityFiltersResults()
        XCTAssertEqual(r.selectedActivityIndex, 0)
        XCTAssertEqual(r.selectedActivity, .running)
        XCTAssertNil(r.gender)
    }

    func test_defaultEndDateTime_isFiveHoursAfterStart() {
        let r   = AvailabilityFiltersResults()
        let diff = r.endDateTime.timeIntervalSince(r.startDateTime)
        XCTAssertEqual(diff, 5 * 3600, accuracy: 60) // within 1 minute
    }

    func test_selectedActivity_matchesIndex() {
        let r = AvailabilityFiltersResults()
        for i in 0..<8 {
            r.selectedActivityIndex = i
            XCTAssertEqual(r.selectedActivity, AvailabilityConfig.activityType(for: i))
        }
    }

    // MARK: buildSearchPayload — always-present keys

    func test_buildSearchPayload_containsBaseKeys() {
        let r = AvailabilityFiltersResults()
        let p = r.buildSearchPayload()
        XCTAssertNotNil(p["activity"])
        XCTAssertNotNil(p["startTime"])
        XCTAssertNotNil(p["endTime"])
    }

    func test_buildSearchPayload_noGenderKey_whenNil() {
        let r = AvailabilityFiltersResults()
        r.gender = nil
        XCTAssertNil(r.buildSearchPayload()["gender"])
    }

    func test_buildSearchPayload_genderKey_whenSet() {
        let r = AvailabilityFiltersResults()
        r.gender = .female
        XCTAssertEqual(r.buildSearchPayload()["gender"] as? String, "Female")
    }

    // MARK: buildSearchPayload — per-activity keys

    func test_buildSearchPayload_running_containsCorrectKeys() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex = 0                    // running
        r.runningFilter.minDistance  = 5.0
        r.runningFilter.maxDistance  = 20.0
        r.runningFilter.minPace      = 4.5
        r.runningFilter.maxPace      = 7.0
        r.runningFilter.runningType  = .trail
        let p = r.buildSearchPayload()

        XCTAssertEqual(p["activity"] as? String, "Running")
        XCTAssertEqual(p["minDistance"] as? Double, 5.0)
        XCTAssertEqual(p["maxDistance"] as? Double, 20.0)
        XCTAssertEqual(p["minPace"]     as? Double, 4.5)
        XCTAssertEqual(p["maxPace"]     as? Double, 7.0)
        XCTAssertEqual(p["runningType"] as? String, "Trail")
    }

    func test_buildSearchPayload_cycling_containsCorrectKeys() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex = 1                    // cycling
        r.cyclingFilter.minPower   = 150.0
        r.cyclingFilter.maxPower   = 300.0
        r.cyclingFilter.minCadence = 70.0
        r.cyclingFilter.maxCadence = 100.0
        r.cyclingFilter.cyclingType = .mountain
        let p = r.buildSearchPayload()

        XCTAssertEqual(p["activity"]    as? String, "Cycling")
        XCTAssertEqual(p["minPower"]    as? Double, 150.0)
        XCTAssertEqual(p["maxPower"]    as? Double, 300.0)
        XCTAssertEqual(p["minCadence"]  as? Double, 70.0)
        XCTAssertEqual(p["maxCadence"]  as? Double, 100.0)
        XCTAssertEqual(p["cyclingType"] as? String, "Mountain")
    }

    func test_buildSearchPayload_gym_containsCorrectKey() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex = 2                    // gym
        r.gymFilter.gymDayType  = .leg
        let p = r.buildSearchPayload()
        XCTAssertEqual(p["activity"]   as? String, "Gym")
        XCTAssertEqual(p["gymDayType"] as? String, "Leg")
    }

    func test_buildSearchPayload_skiing_containsCorrectKeys() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex = 3
        r.skiingFilter.minSpeed = 20.0
        r.skiingFilter.maxSpeed = 80.0
        r.skiingFilter.minDrop  = 200.0
        r.skiingFilter.maxDrop  = 1000.0
        let p = r.buildSearchPayload()
        XCTAssertEqual(p["minSpeed"] as? Double, 20.0)
        XCTAssertEqual(p["maxSpeed"] as? Double, 80.0)
        XCTAssertEqual(p["minDrop"]  as? Double, 200.0)
        XCTAssertEqual(p["maxDrop"]  as? Double, 1000.0)
    }

    func test_buildSearchPayload_swimming_containsCorrectKeys() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex      = 4
        r.swimmingFilter.minDistance = 500.0
        r.swimmingFilter.maxDistance = 2000.0
        r.swimmingFilter.minPace     = 1.5
        r.swimmingFilter.maxPace     = 3.0
        r.swimmingFilter.stroke      = .backstroke
        let p = r.buildSearchPayload()
        XCTAssertEqual(p["stroke"] as? String, "Backstroke")
        XCTAssertEqual(p["minDistance"] as? Double, 500.0)
    }

    func test_buildSearchPayload_hiking_containsCorrectKeys() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex     = 5
        r.hikingFilter.minDistance  = 5.0
        r.hikingFilter.maxDistance  = 30.0
        r.hikingFilter.minElevation = 100.0
        r.hikingFilter.maxElevation = 2000.0
        let p = r.buildSearchPayload()
        XCTAssertEqual(p["minDistance"]  as? Double, 5.0)
        XCTAssertEqual(p["maxElevation"] as? Double, 2000.0)
    }

    func test_buildSearchPayload_yoga_containsCorrectKeys() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex     = 6
        r.yogaFilter.minDuration    = 30.0
        r.yogaFilter.maxDuration    = 90.0
        r.yogaFilter.minIntensity   = 3.0
        r.yogaFilter.maxIntensity   = 8.0
        r.yogaFilter.style          = .hatha
        let p = r.buildSearchPayload()
        XCTAssertEqual(p["style"] as? String, "Hatha")
        XCTAssertEqual(p["minDuration"] as? Double, 30.0)
    }

    func test_buildSearchPayload_tennis_containsCorrectKeys() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex     = 7
        r.tennisFilter.minSets      = 1.0
        r.tennisFilter.maxSets      = 3.0
        r.tennisFilter.minDuration  = 60.0
        r.tennisFilter.maxDuration  = 120.0
        r.tennisFilter.format       = .doubles
        let p = r.buildSearchPayload()
        XCTAssertEqual(p["format"]   as? String, "Doubles")
        XCTAssertEqual(p["minSets"]  as? Double, 1.0)
        XCTAssertEqual(p["maxSets"]  as? Double, 3.0)
    }

    // MARK: buildExtraQueryParams — general

    func test_buildExtraQueryParams_emptyByDefault() {
        // All filter values are nil, gender is nil → should only contain
        // sport-specific keys that are non-nil — which is none
        let r = AvailabilityFiltersResults()
        let p = r.buildExtraQueryParams()
        XCTAssertNil(p["gender"])
        // Running is selected but all values nil → no sport keys
        XCTAssertNil(p["minProposedDistance"])
        XCTAssertNil(p["maxProposedDistance"])
    }

    func test_buildExtraQueryParams_gender_appearsWhenSet() {
        let r = AvailabilityFiltersResults()
        r.gender = .male
        XCTAssertEqual(r.buildExtraQueryParams()["gender"], "Male")
    }

    // MARK: buildExtraQueryParams — per-activity key names

    func test_buildExtraQueryParams_running_correctKeyNames() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex     = 0
        r.runningFilter.minDistance = 5.0
        r.runningFilter.maxDistance = 20.0
        r.runningFilter.minPace     = 4.0
        r.runningFilter.maxPace     = 6.0
        r.runningFilter.runningType = .treadmill
        let p = r.buildExtraQueryParams()

        XCTAssertEqual(p["minProposedDistance"],  "5.0")
        XCTAssertEqual(p["maxProposedDistance"],  "20.0")
        XCTAssertEqual(p["minProposedPace"],      "4.0")
        XCTAssertEqual(p["maxProposedPace"],      "6.0")
        XCTAssertEqual(p["proposedRunningType"],  "Treadmill")
    }

    func test_buildExtraQueryParams_cycling_correctKeyNames() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex      = 1
        r.cyclingFilter.minPower     = 100.0
        r.cyclingFilter.maxPower     = 400.0
        r.cyclingFilter.minCadence   = 60.0
        r.cyclingFilter.maxCadence   = 110.0
        r.cyclingFilter.cyclingType  = .downhill
        let p = r.buildExtraQueryParams()

        XCTAssertEqual(p["minProposedPowerInWatt"],   "100.0")
        XCTAssertEqual(p["maxProposedPowerInWatt"],   "400.0")
        XCTAssertEqual(p["minProposedCadenceInRPM"],  "60.0")
        XCTAssertEqual(p["maxProposedCadenceInRPM"],  "110.0")
        XCTAssertEqual(p["proposedCyclingType"],      "Downhill mountain")
    }

    func test_buildExtraQueryParams_gym_correctKeyName() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex  = 2
        r.gymFilter.gymDayType   = .fullBody
        let p = r.buildExtraQueryParams()
        XCTAssertEqual(p["proposedDayType"], "Full Body")
    }

    func test_buildExtraQueryParams_skiing_correctKeyNames() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex  = 3
        r.skiingFilter.minSpeed  = 10.0
        r.skiingFilter.maxSpeed  = 90.0
        r.skiingFilter.minDrop   = 50.0
        r.skiingFilter.maxDrop   = 1500.0
        let p = r.buildExtraQueryParams()
        XCTAssertEqual(p["minProposedSpeedInKmH"],      "10.0")
        XCTAssertEqual(p["maxProposedSpeedInKmH"],      "90.0")
        XCTAssertEqual(p["minProposedVerticalDropInM"], "50.0")
        XCTAssertEqual(p["maxProposedVerticalDropInM"], "1500.0")
    }

    func test_buildExtraQueryParams_swimming_correctKeyNames() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex      = 4
        r.swimmingFilter.minDistance = 200.0
        r.swimmingFilter.maxDistance = 3000.0
        r.swimmingFilter.minPace     = 1.2
        r.swimmingFilter.maxPace     = 4.0
        r.swimmingFilter.stroke      = .medley
        let p = r.buildExtraQueryParams()
        XCTAssertEqual(p["minProposedDistanceInM"], "200.0")
        XCTAssertEqual(p["maxProposedDistanceInM"], "3000.0")
        XCTAssertEqual(p["minProposedPacePer100M"], "1.2")
        XCTAssertEqual(p["maxProposedPacePer100M"], "4.0")
        XCTAssertEqual(p["proposedStroke"],         "Medley")
    }

    func test_buildExtraQueryParams_hiking_correctKeyNames() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex     = 5
        r.hikingFilter.minDistance  = 3.0
        r.hikingFilter.maxDistance  = 40.0
        r.hikingFilter.minElevation = 0.0
        r.hikingFilter.maxElevation = 3000.0
        let p = r.buildExtraQueryParams()
        XCTAssertEqual(p["minProposedDistanceInKm"],     "3.0")
        XCTAssertEqual(p["maxProposedDistanceInKm"],     "40.0")
        XCTAssertEqual(p["minProposedElevationGainInM"], "0.0")
        XCTAssertEqual(p["maxProposedElevationGainInM"], "3000.0")
    }

    func test_buildExtraQueryParams_yoga_correctKeyNames() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex   = 6
        r.yogaFilter.minDuration  = 20.0
        r.yogaFilter.maxDuration  = 120.0
        r.yogaFilter.minIntensity = 2.0
        r.yogaFilter.maxIntensity = 9.0
        r.yogaFilter.style        = .power
        let p = r.buildExtraQueryParams()
        XCTAssertEqual(p["minProposedDurationInMin"],  "20.0")
        XCTAssertEqual(p["maxProposedDurationInMin"],  "120.0")
        XCTAssertEqual(p["minProposedIntensityLevel"], "2.0")
        XCTAssertEqual(p["maxProposedIntensityLevel"], "9.0")
        XCTAssertEqual(p["proposedStyle"],             "Power")
    }

    func test_buildExtraQueryParams_tennis_correctKeyNames() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex    = 7
        r.tennisFilter.minSets     = 2.0
        r.tennisFilter.maxSets     = 3.0
        r.tennisFilter.minDuration = 45.0
        r.tennisFilter.maxDuration = 180.0
        r.tennisFilter.format      = .singles
        let p = r.buildExtraQueryParams()
        XCTAssertEqual(p["minProposedSets"],          "2.0")
        XCTAssertEqual(p["maxProposedSets"],          "3.0")
        XCTAssertEqual(p["minProposedDurationInMin"], "45.0")
        XCTAssertEqual(p["maxProposedDurationInMin"], "180.0")
        XCTAssertEqual(p["proposedFormat"],           "Singles")
    }

    // MARK: Nil filter values are excluded from query params

    func test_buildExtraQueryParams_nilValues_areExcluded() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex = 0              // running, all nil
        let p = r.buildExtraQueryParams()
        XCTAssertNil(p["minProposedDistance"])
        XCTAssertNil(p["proposedRunningType"])
    }

    func test_buildExtraQueryParams_partialFilters_onlyIncludesSetValues() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex    = 0
        r.runningFilter.minDistance = 10.0
        // maxDistance, pace, runningType remain nil
        let p = r.buildExtraQueryParams()
        XCTAssertEqual(p["minProposedDistance"], "10.0")
        XCTAssertNil(p["maxProposedDistance"])
        XCTAssertNil(p["proposedRunningType"])
    }

    // MARK: Switching activity clears unrelated sport keys from query

    func test_buildExtraQueryParams_doesNotLeakCyclingKeys_whenRunningSelected() {
        let r = AvailabilityFiltersResults()
        r.selectedActivityIndex = 0     // running
        r.cyclingFilter.minPower = 200.0
        let p = r.buildExtraQueryParams()
        XCTAssertNil(p["minProposedPowerInWatt"],
                     "Cycling keys should not appear when Running is selected")
    }
}

// MARK: - FiltersViewModel Tests

final class FiltersViewModelTests: XCTestCase {

    private func makeViewModel(initialIndex: Int = 0) -> (FiltersViewModel, AvailabilityFiltersResults) {
        var results = AvailabilityFiltersResults()
        results.selectedActivityIndex = initialIndex
        // FiltersViewModel uses a Binding — we create one backed by our local var
        // via a simple wrapper using @State is unavailable in unit tests,
        // so we use a manual Binding.
        var captured = results
        let binding = Binding<AvailabilityFiltersResults>(
            get: { captured },
            set: { captured = $0 }
        )
        let vm = FiltersViewModel(availabilityFiltersResults: binding)
        return (vm, captured)
    }

    func test_initialSelectedActivityIndex_matchesResults() {
        let (vm, _) = makeViewModel(initialIndex: 3)
        XCTAssertEqual(vm.selectedActivityIndex, 3)
    }

    func test_selectedActivityType_matchesIndex() {
        let (vm, _) = makeViewModel()
        for i in 0..<8 {
            vm.selectedActivityIndex = i
            XCTAssertEqual(vm.selectedActivityType, AvailabilityConfig.activityType(for: i))
        }
    }

    func test_icons_countMatchesActivityNames() {
        let (vm, _) = makeViewModel()
        XCTAssertEqual(vm.icons.count, vm.activityNames.count)
    }

    func test_icons_matchConfig() {
        let (vm, _) = makeViewModel()
        XCTAssertEqual(vm.icons, AvailabilityConfig.icons)
    }

    func test_activityNames_matchConfig() {
        let (vm, _) = makeViewModel()
        XCTAssertEqual(vm.activityNames, AvailabilityConfig.activityNames)
    }

    func test_isWheelBig_defaultsFalse() {
        let (vm, _) = makeViewModel()
        XCTAssertFalse(vm.isWheelBig)
    }

    func test_changingSelectedIndex_updatesActivityType() {
        let (vm, _) = makeViewModel()
        vm.selectedActivityIndex = 6       // yoga
        XCTAssertEqual(vm.selectedActivityType, .yoga)
        vm.selectedActivityIndex = 1       // cycling
        XCTAssertEqual(vm.selectedActivityType, .cycling)
    }
}
