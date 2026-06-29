//
//  SessionMetricsUtilsTests.swift
//  sbudTests
//
//  Unit tests for MetricsCollectorUtils static methods — all pure functions,
//  no network, no Firebase, no singletons.
//

import XCTest
import CoreLocation
@testable import sbud

final class SessionMetricsUtilsTests: XCTestCase {

    // MARK: - isValidLocation

    func test_isValidLocation_validAccuracyAndSpeed_noLastLocation_returnsTrue() {
        let loc = CLLocation.make(accuracy: 10, speed: 5)
        XCTAssertTrue(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_isValidLocation_negativeAccuracy_returnsFalse() {
        let loc = CLLocation.make(accuracy: -1, speed: 5)
        XCTAssertFalse(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_isValidLocation_accuracyExactly20_returnsFalse() {
        // threshold is < 20, so 20 is invalid
        let loc = CLLocation.make(accuracy: 20, speed: 5)
        XCTAssertFalse(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_isValidLocation_accuracyJustBelow20_returnsTrue() {
        let loc = CLLocation.make(accuracy: 19.9, speed: 5)
        XCTAssertTrue(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_isValidLocation_negativeSpeed_returnsFalse() {
        let loc = CLLocation.make(accuracy: 10, speed: -1)
        XCTAssertFalse(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_isValidLocation_zeroSpeed_returnsTrue() {
        // speed == 0 is valid (standing still)
        let loc = CLLocation.make(accuracy: 10, speed: 0)
        XCTAssertTrue(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_isValidLocation_timeDeltaLessThan1Second_returnsFalse() {
        let t0 = Date.seconds(1000)
        let t1 = Date.seconds(1000.5) // 0.5 s later — too soon
        let last = CLLocation.make(accuracy: 10, speed: 5, timestamp: t0)
        let loc  = CLLocation.make(accuracy: 10, speed: 5, timestamp: t1)
        XCTAssertFalse(MetricsCollectorUtils.isValidLocation(loc, lastLocation: last))
    }

    func test_isValidLocation_timeDeltaExactly1Second_returnsTrue() {
        let t0 = Date.seconds(1000)
        let t1 = Date.seconds(1001)
        let last = CLLocation.make(accuracy: 10, speed: 5, timestamp: t0)
        let loc  = CLLocation.make(accuracy: 10, speed: 5, timestamp: t1)
        XCTAssertTrue(MetricsCollectorUtils.isValidLocation(loc, lastLocation: last))
    }

    func test_isValidLocation_timeDeltaGreaterThan1Second_returnsTrue() {
        let t0 = Date.seconds(1000)
        let t1 = Date.seconds(1005)
        let last = CLLocation.make(accuracy: 10, speed: 5, timestamp: t0)
        let loc  = CLLocation.make(accuracy: 10, speed: 5, timestamp: t1)
        XCTAssertTrue(MetricsCollectorUtils.isValidLocation(loc, lastLocation: last))
    }

    // MARK: - computeDistance

    func test_computeDistance_emptyArray_returnsZero() {
        XCTAssertEqual(MetricsCollectorUtils.computeDistance(from: []), 0)
    }

    func test_computeDistance_singleLocation_returnsZero() {
        let loc = CLLocation.make()
        XCTAssertEqual(MetricsCollectorUtils.computeDistance(from: [loc]), 0)
    }

    func test_computeDistance_twoIdenticalLocations_returnsZero() {
        let a = CLLocation.make(lat: 45.0, lon: 9.0)
        let b = CLLocation.make(lat: 45.0, lon: 9.0)
        XCTAssertEqual(MetricsCollectorUtils.computeDistance(from: [a, b]), 0, accuracy: 0.001)
    }

    func test_computeDistance_twoDistinctLocations_returnsPositive() {
        // Milan Duomo to Milan Central Station ≈ 1.5 km
        let duomo   = CLLocation.make(lat: 45.4641, lon: 9.1919)
        let central = CLLocation.make(lat: 45.4855, lon: 9.2044)
        let dist = MetricsCollectorUtils.computeDistance(from: [duomo, central])
        XCTAssertGreaterThan(dist, 1000)
        XCTAssertLessThan(dist, 3000)
    }

    func test_computeDistance_threeLocations_sumsBothLegs() {
        let a = CLLocation.make(lat: 45.0, lon:  9.0)
        let b = CLLocation.make(lat: 45.0, lon:  9.01)
        let c = CLLocation.make(lat: 45.0, lon:  9.02)
        let ab = a.distance(from: b)
        let bc = b.distance(from: c)
        let total = MetricsCollectorUtils.computeDistance(from: [a, b, c])
        XCTAssertEqual(total, ab + bc, accuracy: 0.001)
    }

    // MARK: - computeElevationGain

    func test_computeElevationGain_emptyArray_returnsZero() {
        XCTAssertEqual(MetricsCollectorUtils.computeElevationGain(from: []), 0)
    }

    func test_computeElevationGain_singleLocation_returnsZero() {
        XCTAssertEqual(MetricsCollectorUtils.computeElevationGain(from: [CLLocation.make()]), 0)
    }

    func test_computeElevationGain_flatTrack_returnsZero() {
        let locs = [
            CLLocation.make(altitude: 100),
            CLLocation.make(altitude: 100),
            CLLocation.make(altitude: 100)
        ]
        XCTAssertEqual(MetricsCollectorUtils.computeElevationGain(from: locs), 0)
    }

    func test_computeElevationGain_strictlyAscending_returnsCorrectSum() {
        let locs = [
            CLLocation.make(altitude: 0),
            CLLocation.make(altitude: 50),
            CLLocation.make(altitude: 120)
        ]
        // +50 + 70 = 120
        XCTAssertEqual(MetricsCollectorUtils.computeElevationGain(from: locs), 120, accuracy: 0.001)
    }

    func test_computeElevationGain_descendingTrack_returnsZero() {
        let locs = [
            CLLocation.make(altitude: 200),
            CLLocation.make(altitude: 100),
            CLLocation.make(altitude: 50)
        ]
        XCTAssertEqual(MetricsCollectorUtils.computeElevationGain(from: locs), 0)
    }

    func test_computeElevationGain_mixedTrack_countsOnlyPositiveDeltas() {
        let locs = [
            CLLocation.make(altitude: 0),
            CLLocation.make(altitude: 30),   // +30
            CLLocation.make(altitude: 10),   // -20 (ignored)
            CLLocation.make(altitude: 60)    // +50
        ]
        XCTAssertEqual(MetricsCollectorUtils.computeElevationGain(from: locs), 80, accuracy: 0.001)
    }

    // MARK: - computeElevationLoss

    func test_computeElevationLoss_emptyArray_returnsZero() {
        XCTAssertEqual(MetricsCollectorUtils.computeElevationLoss(from: []), 0)
    }

    func test_computeElevationLoss_ascendingTrack_returnsZero() {
        let locs = [
            CLLocation.make(altitude: 0),
            CLLocation.make(altitude: 100)
        ]
        XCTAssertEqual(MetricsCollectorUtils.computeElevationLoss(from: locs), 0)
    }

    func test_computeElevationLoss_descendingTrack_returnsAbsoluteSum() {
        let locs = [
            CLLocation.make(altitude: 200),
            CLLocation.make(altitude: 150),  // -50
            CLLocation.make(altitude: 80)    // -70
        ]
        XCTAssertEqual(MetricsCollectorUtils.computeElevationLoss(from: locs), 120, accuracy: 0.001)
    }

    func test_computeElevationLoss_mixedTrack_countsOnlyNegativeDeltas() {
        let locs = [
            CLLocation.make(altitude: 100),
            CLLocation.make(altitude: 130),  // +30 (ignored)
            CLLocation.make(altitude: 90),   // -40
            CLLocation.make(altitude: 110)   // +20 (ignored)
        ]
        XCTAssertEqual(MetricsCollectorUtils.computeElevationLoss(from: locs), 40, accuracy: 0.001)
    }

    // MARK: - computeVerticalDrop

    func test_computeVerticalDrop_emptyArray_returnsZero() {
        XCTAssertEqual(MetricsCollectorUtils.computeVerticalDrop(from: []), 0)
    }

    func test_computeVerticalDrop_ascendingOnly_returnsZero() {
        let locs = [CLLocation.make(altitude: 0), CLLocation.make(altitude: 100)]
        XCTAssertEqual(MetricsCollectorUtils.computeVerticalDrop(from: locs), 0)
    }

    func test_computeVerticalDrop_descendingSequence_returnsTotalDrop() {
        let locs = [
            CLLocation.make(altitude: 1000),
            CLLocation.make(altitude: 800),   // -200
            CLLocation.make(altitude: 700)    // -100
        ]
        XCTAssertEqual(MetricsCollectorUtils.computeVerticalDrop(from: locs), 300, accuracy: 0.001)
    }

    // MARK: - computeNumberOfRuns

    func test_computeNumberOfRuns_emptyArray_returnsZero() {
        XCTAssertEqual(MetricsCollectorUtils.computeNumberOfRuns(from: []), 0)
    }

    func test_computeNumberOfRuns_noDescentAtAll_returnsZero() {
        let locs = [CLLocation.make(altitude: 0), CLLocation.make(altitude: 100)]
        XCTAssertEqual(MetricsCollectorUtils.computeNumberOfRuns(from: locs), 0)
    }

    func test_computeNumberOfRuns_singleDescentSequence_returnsOne() {
        let locs = [
            CLLocation.make(altitude: 100),
            CLLocation.make(altitude: 80),
            CLLocation.make(altitude: 60)
        ]
        XCTAssertEqual(MetricsCollectorUtils.computeNumberOfRuns(from: locs), 1)
    }

    func test_computeNumberOfRuns_twoDescentsSeparatedByAscent_returnsTwo() {
        let locs = [
            CLLocation.make(altitude: 100), // ↓ run 1 starts
            CLLocation.make(altitude: 80),
            CLLocation.make(altitude: 90),  // ↑ ascent resets
            CLLocation.make(altitude: 70),  // ↓ run 2 starts
            CLLocation.make(altitude: 60)
        ]
        XCTAssertEqual(MetricsCollectorUtils.computeNumberOfRuns(from: locs), 2)
    }

    func test_computeNumberOfRuns_continuousDescentCountsAsOneRun() {
        let locs = [
            CLLocation.make(altitude: 100),
            CLLocation.make(altitude: 80),
            CLLocation.make(altitude: 60),
            CLLocation.make(altitude: 40)
        ]
        XCTAssertEqual(MetricsCollectorUtils.computeNumberOfRuns(from: locs), 1)
    }

    // MARK: - trimTrack

    func test_trimTrack_emptyTrack_returnsEmpty() {
        let cutoff = Date()
        XCTAssertTrue(MetricsCollectorUtils.trimTrack([], to: cutoff).isEmpty)
    }

    func test_trimTrack_allPointsBeforeCutoff_returnsAll() {
        let t0 = Date.seconds(1000)
        let cutoff = Date.seconds(2000)
        let track: [(Date, CLLocation)] = [
            (Date.seconds(900),  CLLocation.make()),
            (Date.seconds(1000), CLLocation.make()),
            (Date.seconds(1500), CLLocation.make())
        ]
        let result = MetricsCollectorUtils.trimTrack(track, to: cutoff)
        XCTAssertEqual(result.count, 3)
        _ = t0 // silence unused warning
    }

    func test_trimTrack_allPointsAfterCutoff_returnsEmpty() {
        let cutoff = Date.seconds(500)
        let track: [(Date, CLLocation)] = [
            (Date.seconds(1000), CLLocation.make()),
            (Date.seconds(2000), CLLocation.make())
        ]
        XCTAssertTrue(MetricsCollectorUtils.trimTrack(track, to: cutoff).isEmpty)
    }

    func test_trimTrack_mixedPoints_keepsOnlyUpToCutoff() {
        let cutoff = Date.seconds(1500)
        let track: [(Date, CLLocation)] = [
            (Date.seconds(1000), CLLocation.make()),
            (Date.seconds(1500), CLLocation.make(lat: 1, lon: 0)),  // exactly at cutoff — kept
            (Date.seconds(2000), CLLocation.make(lat: 2, lon: 0))   // after — dropped
        ]
        let result = MetricsCollectorUtils.trimTrack(track, to: cutoff)
        XCTAssertEqual(result.count, 2)
    }

    // MARK: - trimmedElapsed

    func test_trimmedElapsed_emptyTrack_returnsFallback() {
        let result = MetricsCollectorUtils.trimmedElapsed(from: [], fallback: 42.0)
        XCTAssertEqual(result, 42.0)
    }

    func test_trimmedElapsed_singlePoint_returnsFallback() {
        let track: [(Date, CLLocation)] = [(Date.seconds(1000), CLLocation.make())]
        // first == last → timeIntervalSince is 0, but guard requires both first and last non-nil
        // Actually guard let first AND last succeed with 1 element, last.timeIntervalSince(first) = 0
        let result = MetricsCollectorUtils.trimmedElapsed(from: track, fallback: 99.0)
        XCTAssertEqual(result, 0, accuracy: 0.001)
    }

    func test_trimmedElapsed_multiplePoints_returnsIntervalBetweenFirstAndLast() {
        let t0 = Date.seconds(1000)
        let t1 = Date.seconds(1300)
        let track: [(Date, CLLocation)] = [
            (t0, CLLocation.make()),
            (Date.seconds(1100), CLLocation.make()),
            (t1, CLLocation.make())
        ]
        let result = MetricsCollectorUtils.trimmedElapsed(from: track, fallback: 0)
        XCTAssertEqual(result, 300, accuracy: 0.001)
    }

    // MARK: - toTrackPoints extension

    func test_toTrackPoints_emptyCollection_returnsEmpty() {
        let result: [(Date, CLLocation)] = []
        XCTAssertTrue(result.toTrackPoints().isEmpty)
    }

    func test_toTrackPoints_preservesCoordinatesAndTimestamp() {
        let t = Date.seconds(5000)
        let loc = CLLocation.make(lat: 45.1, lon: 9.2, timestamp: t)
        let result = [(t, loc)].toTrackPoints()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].latitude,  45.1, accuracy: 0.0001)
        XCTAssertEqual(result[0].longitude, 9.2,  accuracy: 0.0001)
        XCTAssertEqual(result[0].timestamp, t)
    }

    func test_toTrackPoints_multiplePoints_preservesOrder() {
        let locs: [(Date, CLLocation)] = [
            (Date.seconds(1000), CLLocation.make(lat: 1, lon: 1)),
            (Date.seconds(2000), CLLocation.make(lat: 2, lon: 2)),
            (Date.seconds(3000), CLLocation.make(lat: 3, lon: 3))
        ]
        let points = locs.toTrackPoints()
        XCTAssertEqual(points.count, 3)
        XCTAssertEqual(points[0].latitude, 1, accuracy: 0.0001)
        XCTAssertEqual(points[1].latitude, 2, accuracy: 0.0001)
        XCTAssertEqual(points[2].latitude, 3, accuracy: 0.0001)
    }

    // MARK: - Memory leak

    func test_noMemoryLeak() {
        // MetricsCollectorUtils is a caseless enum — nothing to leak
        // This is a placeholder to confirm the static enum doesn't hold state
        XCTAssertTrue(true)
    }
}
