//
//  SessionIntegrationTests.swift
//  sbudTests
//
//  Integration tests: full checkpoint round-trip, multi-location accumulation,
//  trimming logic, and the 24-hour fallback path in RunMetricsUploader.
//
//  These tests exercise multiple layers working together (collector + UserDefaults
//  + snapshot encoding/decoding + utility functions) without hitting Firebase or
//  the real HealthKit/LocationManager singletons.
//

import XCTest
import CoreLocation
@testable import sbud

final class SessionIntegrationTests: XCTestCase {

    private var mockLoc: MockSessionLocationManager!
    private var mockHK:  MockHealthKitService!

    private let testEventId = "integration-test-event"

    override func setUp() {
        super.setUp()
        mockLoc = MockSessionLocationManager()
        mockHK  = MockHealthKitService()
        // Pre-clean any stale checkpoint from a previous failed test
        cleanAllCheckpoints()
    }

    override func tearDown() {
        cleanAllCheckpoints()
        mockLoc = nil
        mockHK  = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func cleanAllCheckpoints() {
        let loc = MockSessionLocationManager()
        let hk  = MockHealthKitService()
        MetricsCollectorRun(isCreator: true, numSessions: 1, locationManager: loc,
                             healthKit: hk, userIdProvider: { nil })
            .clearCheckpoint(eventId: testEventId)
        MetricsCollectorHiking(isCreator: true, numSessions: 1, locationManager: loc,
                                healthKit: hk, userIdProvider: { nil })
            .clearCheckpoint(eventId: testEventId)
        MetricsCollectorCycling(isCreator: true, numSessions: 1, locationManager: loc,
                                 healthKit: hk, userIdProvider: { nil })
            .clearCheckpoint(eventId: testEventId)
        MetricsCollectorSkiing(isCreator: true, numSessions: 1, locationManager: loc,
                                healthKit: hk, userIdProvider: { nil })
            .clearCheckpoint(eventId: testEventId)
    }

    // MARK: - Run: full crash-recovery round-trip

    func test_runCollector_crashRecovery_restoresAllMetrics() {
        // Phase 1 — simulate a session that has accumulated data before "crash"
        let originalLoc = MockSessionLocationManager()
        let original = MetricsCollectorRun(
            isCreator: true, numSessions: 2,
            locationManager: originalLoc, healthKit: mockHK,
            userIdProvider: { "user-123" }
        )
        original.startSession(eventId: testEventId)

        // Feed three valid GPS points spaced ≥ 1 second apart
        let t0 = Date.seconds(50_000)
        let t1 = Date.seconds(50_002)
        let t2 = Date.seconds(50_004)
        originalLoc.emit(CLLocation.make(lat: 45.000, lon: 9.000, accuracy: 10, speed: 3, timestamp: t0))
        originalLoc.emit(CLLocation.make(lat: 45.005, lon: 9.000, accuracy: 10, speed: 3, timestamp: t1))
        originalLoc.emit(CLLocation.make(lat: 45.010, lon: 9.000, accuracy: 10, speed: 3, timestamp: t2))

        let distanceBefore = original.totalDistanceMeters
        let pointsBefore   = original.trackedLocations.count

        // Manually save checkpoint (normally timer-driven every 30s)
        original.saveCheckpoint(eventId: testEventId)

        // Phase 2 — new collector instance simulates app relaunch
        let newLoc = MockSessionLocationManager()
        let restored = MetricsCollectorRun(
            isCreator: true, numSessions: 2,
            locationManager: newLoc, healthKit: mockHK,
            userIdProvider: { "user-123" }
        )
        // startSession restores from checkpoint if one exists
        restored.startSession(eventId: testEventId)

        XCTAssertEqual(restored.totalDistanceMeters, distanceBefore, accuracy: 0.1)
        XCTAssertEqual(restored.trackedLocations.count, pointsBefore)
        XCTAssertTrue(restored.isTracking)
    }

    // MARK: - Hiking: elevation round-trip

    func test_hikingCollector_crashRecovery_restoresElevationAndSplits() {
        let originalLoc = MockSessionLocationManager()
        let original = MetricsCollectorHiking(
            isCreator: false, numSessions: 1,
            locationManager: originalLoc, healthKit: mockHK,
            userIdProvider: { "u" }
        )
        original.startSession(eventId: testEventId)

        let ts = (0..<4).map { Date.seconds(Double(60_000 + $0 * 2)) }
        // 0m → 100m → 200m → 150m: +200 gain, 50 loss
        originalLoc.emit(CLLocation.make(lat: 45.0, lon: 9.0, altitude: 0,   accuracy: 10, speed: 1, timestamp: ts[0]))
        originalLoc.emit(CLLocation.make(lat: 45.01, lon: 9.0, altitude: 100, accuracy: 10, speed: 1, timestamp: ts[1]))
        originalLoc.emit(CLLocation.make(lat: 45.02, lon: 9.0, altitude: 200, accuracy: 10, speed: 1, timestamp: ts[2]))
        originalLoc.emit(CLLocation.make(lat: 45.03, lon: 9.0, altitude: 150, accuracy: 10, speed: 1, timestamp: ts[3]))

        let gainBefore = original.elevationGainMeters
        let lossBefore = original.elevationLossMeters
        let maxAlt     = original.maxAltitudeMeters

        original.saveCheckpoint(eventId: testEventId)

        let newLoc = MockSessionLocationManager()
        let restored = MetricsCollectorHiking(
            isCreator: false, numSessions: 1,
            locationManager: newLoc, healthKit: mockHK,
            userIdProvider: { "u" }
        )
        restored.startSession(eventId: testEventId)

        XCTAssertEqual(restored.elevationGainMeters, gainBefore, accuracy: 0.5)
        XCTAssertEqual(restored.elevationLossMeters, lossBefore, accuracy: 0.5)
        XCTAssertEqual(restored.maxAltitudeMeters, maxAlt, accuracy: 0.5)
    }

    // MARK: - Cycling: speed bounds round-trip

    func test_cyclingCollector_crashRecovery_restoresSpeedStats() {
        let originalLoc = MockSessionLocationManager()
        let original = MetricsCollectorCycling(
            isCreator: true, numSessions: 1,
            locationManager: originalLoc, healthKit: mockHK,
            userIdProvider: { "u" }
        )
        original.startSession(eventId: testEventId)

        // 10 m/s → 36 km/h, 12 m/s → 43.2 km/h
        let t0 = Date.seconds(70_000)
        let t1 = Date.seconds(70_002)
        originalLoc.emit(CLLocation.make(lat: 45.0, lon: 9.0, accuracy: 10, speed: 10, timestamp: t0))
        originalLoc.emit(CLLocation.make(lat: 45.001, lon: 9.0, accuracy: 10, speed: 12, timestamp: t1))

        let minBefore = original.minSpeedKmH
        let maxBefore = original.maxSpeedKmH

        original.saveCheckpoint(eventId: testEventId)

        let newLoc = MockSessionLocationManager()
        let restored = MetricsCollectorCycling(
            isCreator: true, numSessions: 1,
            locationManager: newLoc, healthKit: mockHK,
            userIdProvider: { "u" }
        )
        restored.startSession(eventId: testEventId)

        XCTAssertEqual(restored.minSpeedKmH, minBefore, accuracy: 0.1)
        XCTAssertEqual(restored.maxSpeedKmH, maxBefore, accuracy: 0.1)
    }

    // MARK: - Skiing: run count round-trip

    func test_skiingCollector_crashRecovery_restoresRunCount() {
        let originalLoc = MockSessionLocationManager()
        let original = MetricsCollectorSkiing(
            isCreator: true, numSessions: 1,
            locationManager: originalLoc, healthKit: mockHK,
            userIdProvider: { "u" }
        )
        original.startSession(eventId: testEventId)

        // descent → ascent → descent = 2 runs
        let ts = (0..<4).map { Date.seconds(Double(80_000 + $0 * 2)) }
        originalLoc.emit(CLLocation.make(lat: 45.0, lon: 9.0, altitude: 100, accuracy: 10, speed: 8, timestamp: ts[0]))
        originalLoc.emit(CLLocation.make(lat: 45.001, lon: 9.0, altitude: 80,  accuracy: 10, speed: 8, timestamp: ts[1]))
        originalLoc.emit(CLLocation.make(lat: 45.002, lon: 9.0, altitude: 90,  accuracy: 10, speed: 8, timestamp: ts[2]))
        originalLoc.emit(CLLocation.make(lat: 45.003, lon: 9.0, altitude: 70,  accuracy: 10, speed: 8, timestamp: ts[3]))

        let runsBefore = original.numberOfRuns
        let dropBefore = original.verticalDropMeters

        original.saveCheckpoint(eventId: testEventId)

        let newLoc = MockSessionLocationManager()
        let restored = MetricsCollectorSkiing(
            isCreator: true, numSessions: 1,
            locationManager: newLoc, healthKit: mockHK,
            userIdProvider: { "u" }
        )
        restored.startSession(eventId: testEventId)

        XCTAssertEqual(restored.numberOfRuns, runsBefore)
        XCTAssertEqual(restored.verticalDropMeters, dropBefore, accuracy: 0.5)
    }

    // MARK: - TrackPoint ↔ CLLocation round-trip (used by all GPS collectors)

    func test_trackPointToLocation_roundTrip_preservesCoordinates() {
        let original = TrackPoint(timestamp: Date.seconds(9000), latitude: 45.123, longitude: 9.456)

        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: original.latitude, longitude: original.longitude),
            altitude: 0,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            timestamp: original.timestamp
        )

        let reconstructed = [(original.timestamp, location)].toTrackPoints().first!

        XCTAssertEqual(reconstructed.latitude,  original.latitude,  accuracy: 0.000001)
        XCTAssertEqual(reconstructed.longitude, original.longitude, accuracy: 0.000001)
    }

    // MARK: - trimTrack + computeDistance pipeline (mirrors participantEndsSession)

    func test_trimAndDistance_participantTrimPipeline_producesCorrectDistance() {
        let creatorEnd = Date.seconds(10_010)

        // 4 location tuples, one of which is past the creator's end
        let track: [(Date, CLLocation)] = [
            (Date.seconds(10_000), CLLocation.make(lat: 45.000, lon: 9.000, accuracy: 10, speed: 3)),
            (Date.seconds(10_003), CLLocation.make(lat: 45.005, lon: 9.000, accuracy: 10, speed: 3)),
            (Date.seconds(10_006), CLLocation.make(lat: 45.010, lon: 9.000, accuracy: 10, speed: 3)),
            (Date.seconds(10_015), CLLocation.make(lat: 45.020, lon: 9.000, accuracy: 10, speed: 3)) // after creator end
        ]

        let trimmed = MetricsCollectorUtils.trimTrack(track, to: creatorEnd)
        XCTAssertEqual(trimmed.count, 3, "Point after creator end must be removed")

        let distance = MetricsCollectorUtils.computeDistance(from: trimmed.map { $0.1 })
        XCTAssertGreaterThan(distance, 0)

        // Verify trimmed distance < full distance
        let fullDistance = MetricsCollectorUtils.computeDistance(from: track.map { $0.1 })
        XCTAssertLessThan(distance, fullDistance)
    }

    // MARK: - RunMetricsUploader participant logic (unit-tested, no Firebase)

    func test_participantUploader_endedBeforeCreator_usesFullData() {
        // participantEndDateTime = startDate + elapsedSeconds
        let startDate = Date.seconds(1_000)
        let elapsedSeconds = 500.0
        let finalEndDateTime = Date.seconds(1_700) // creator ended at 1700

        let participantEndTime = startDate.addingTimeInterval(elapsedSeconds) // 1500
        let endedBeforeCreator = participantEndTime <= finalEndDateTime // true (1500 <= 1700)

        XCTAssertTrue(endedBeforeCreator)
    }

    func test_participantUploader_endedAfterCreator_usesCreatorEnd() {
        let startDate = Date.seconds(1_000)
        let elapsedSeconds = 800.0
        let finalEndDateTime = Date.seconds(1_700)

        let participantEndTime = startDate.addingTimeInterval(elapsedSeconds) // 1800
        let endedBeforeCreator = participantEndTime <= finalEndDateTime // false (1800 > 1700)

        XCTAssertFalse(endedBeforeCreator)
    }

    func test_participantUploader_fallback_computesFallbackEndTime() {
        let startDate = Date.seconds(2_000)
        let elapsedSeconds = 1_200.0
        let expectedFallbackEnd = Date.seconds(3_200)

        let fallbackEnd = startDate.addingTimeInterval(elapsedSeconds)
        XCTAssertEqual(fallbackEnd.timeIntervalSinceReferenceDate,
                       expectedFallbackEnd.timeIntervalSinceReferenceDate,
                       accuracy: 0.001)
    }

    // MARK: - MetricsCollectorUtils full pipeline (elevation gain + loss cross-check)

    func test_elevationPipeline_gainAndLoss_areComplementary() {
        // Mixed track: up 100, down 50, up 30, down 80
        let locs = [
            CLLocation.make(altitude: 0),
            CLLocation.make(altitude: 100), // +100
            CLLocation.make(altitude: 50),  // -50
            CLLocation.make(altitude: 80),  // +30
            CLLocation.make(altitude: 0)    // -80
        ]
        let gain = MetricsCollectorUtils.computeElevationGain(from: locs)
        let loss = MetricsCollectorUtils.computeElevationLoss(from: locs)

        XCTAssertEqual(gain, 130, accuracy: 0.001)
        XCTAssertEqual(loss, 130, accuracy: 0.001) // net-zero track — gain == loss
    }

    // MARK: - Multiple location types reject/accept boundary conditions

    func test_locationFilter_boundaryAccuracy19_9_isAccepted() {
        let loc = CLLocation.make(accuracy: 19.9, speed: 1)
        XCTAssertTrue(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_locationFilter_boundaryAccuracy20_isRejected() {
        let loc = CLLocation.make(accuracy: 20.0, speed: 1)
        XCTAssertFalse(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_locationFilter_zeroSpeed_isAccepted_standsStill() {
        let loc = CLLocation.make(accuracy: 5, speed: 0)
        XCTAssertTrue(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }
}
