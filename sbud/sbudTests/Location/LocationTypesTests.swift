//
//  LocationTypesTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 06/07/2026.
//


import XCTest
import CoreLocation
@testable import sbud

final class LocationTypesTests: XCTestCase {

    // MARK: - ActivityType

    func test_activityType_hasEightCases() {
        XCTAssertEqual(ActivityType.allCases.count, 8)
    }

    func test_activityType_rawValues_matchBackendStrings() {
        XCTAssertEqual(ActivityType.running.rawValue, "Running")
        XCTAssertEqual(ActivityType.cycling.rawValue, "Cycling")
        XCTAssertEqual(ActivityType.gym.rawValue, "Gym")
        XCTAssertEqual(ActivityType.skiing.rawValue, "Skiing")
        XCTAssertEqual(ActivityType.swimming.rawValue, "Swimming")
        XCTAssertEqual(ActivityType.hiking.rawValue, "Hiking")
        XCTAssertEqual(ActivityType.yoga.rawValue, "Yoga")
        XCTAssertEqual(ActivityType.tennis.rawValue, "Tennis")
    }

    func test_activityType_everyCase_hasNonEmptyIcon() {
        for activity in ActivityType.allCases {
            XCTAssertFalse(activity.icon.isEmpty, "\(activity) deve avere un'icona")
        }
    }

    func test_activityType_icons_areCorrectSFSymbols() {
        XCTAssertEqual(ActivityType.running.icon, "figure.run")
        XCTAssertEqual(ActivityType.cycling.icon, "figure.outdoor.cycle")
        XCTAssertEqual(ActivityType.gym.icon, "dumbbell")
        XCTAssertEqual(ActivityType.tennis.icon, "figure.tennis")
    }

    func test_activityType_decodesFromJSON() throws {
        let json = "\"Running\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(ActivityType.self, from: json)
        XCTAssertEqual(decoded, .running)
    }

    func test_activityType_invalidRawValue_failsDecoding() {
        let json = "\"Parkour\"".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(ActivityType.self, from: json))
    }

    // MARK: - ActivityMetrics (Codable round-trip)

    func test_activityMetrics_empty_encodesAndDecodes() throws {
        let metrics = ActivityMetrics()

        let data = try JSONEncoder().encode(metrics)
        let decoded = try JSONDecoder().decode(ActivityMetrics.self, from: data)

        XCTAssertEqual(decoded, metrics)
    }

    func test_activityMetrics_withRunningData_roundTripsCorrectly() throws {
        var metrics = ActivityMetrics()
        metrics.running = RunningData(preferredDistance: 10.5, preferredPace: 5.2, preferredType: .road)

        let data = try JSONEncoder().encode(metrics)
        let decoded = try JSONDecoder().decode(ActivityMetrics.self, from: data)

        XCTAssertEqual(decoded.running?.preferredDistance, 10.5)
        XCTAssertEqual(decoded.running?.preferredPace, 5.2)
        XCTAssertNil(decoded.cycling, "I campi non impostati devono restare nil")
    }

    func test_runningData_defaults() {
        let data = RunningData()
        XCTAssertEqual(data.preferredDistance, 0.0)
        XCTAssertEqual(data.preferredPace, 0.0)
        XCTAssertEqual(data.preferredType, .road)
    }

    func test_swimmingData_defaults() {
        let data = SwimmingData()
        XCTAssertEqual(data.preferredStroke, .freestyle)
    }

    func test_tennisData_defaults() {
        let data = TennisData()
        XCTAssertEqual(data.preferredFormat, .singles)
    }

    func test_activityMetrics_equatable_detectsDifference() {
        var a = ActivityMetrics()
        a.gym = GymData(preferredDayType: .push)
        var b = ActivityMetrics()
        b.gym = GymData(preferredDayType: .push)

        XCTAssertEqual(a, b)

        b.gym = nil
        XCTAssertNotEqual(a, b)
    }
}