//
//  AvailabilityConfigTests.swift
//  sbudTests
//

import XCTest
@testable import sbud

final class AvailabilityConfigTests: XCTestCase {

    // MARK: - activityType(for:)

    func test_index0_returnsRunning() {
        XCTAssertEqual(AvailabilityConfig.activityType(for: 0), .running)
    }

    func test_index1_returnsCycling() {
        XCTAssertEqual(AvailabilityConfig.activityType(for: 1), .cycling)
    }

    func test_index2_returnsGym() {
        XCTAssertEqual(AvailabilityConfig.activityType(for: 2), .gym)
    }

    func test_index3_returnsSkiing() {
        XCTAssertEqual(AvailabilityConfig.activityType(for: 3), .skiing)
    }

    func test_index4_returnsSwimming() {
        XCTAssertEqual(AvailabilityConfig.activityType(for: 4), .swimming)
    }

    func test_index5_returnsHiking() {
        XCTAssertEqual(AvailabilityConfig.activityType(for: 5), .hiking)
    }

    func test_index6_returnsYoga() {
        XCTAssertEqual(AvailabilityConfig.activityType(for: 6), .yoga)
    }

    func test_index7_returnsTennis() {
        XCTAssertEqual(AvailabilityConfig.activityType(for: 7), .tennis)
    }

    // Regression: out-of-range index must not crash and must return .running
    func test_outOfRangeIndex_defaultsToRunning() {
        XCTAssertEqual(AvailabilityConfig.activityType(for: 99), .running)
        XCTAssertEqual(AvailabilityConfig.activityType(for: -1), .running)
    }

    // MARK: - Static arrays are consistent

    func test_activityNamesCount_matchesIconsCount() {
        XCTAssertEqual(AvailabilityConfig.activityNames.count, AvailabilityConfig.icons.count)
    }

    func test_activityNamesCount_coversAllIndices() {
        // Every index that activityType(for:) handles (0-7) should have a name
        for i in 0..<AvailabilityConfig.activityNames.count {
            let type = AvailabilityConfig.activityType(for: i)
            XCTAssertNotNil(type, "Index \(i) has no mapped ActivityType")
        }
    }
}
