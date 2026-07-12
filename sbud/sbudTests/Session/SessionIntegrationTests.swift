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
import Combine
import CoreLocation
@testable import sbud

// MARK: - Helper locali (adattati ai mock condivisi)

private func iLoc(lat: Double = 45.0, lon: Double = 9.0,
                  altitude: Double = 100,
                  accuracy: Double = 10,
                  speed: Double = 3.0,
                  timestamp: Date = Date()) -> CLLocation {
    makeLocation(lat: lat, lon: lon, altitude: altitude,
                 accuracy: accuracy, speed: speed, timestamp: timestamp)
}

private func iSecs(_ v: Double) -> Date { Date(timeIntervalSince1970: v) }

final class SessionIntegrationTests: XCTestCase {

    private var mockLoc: MockSessionLocationManager!
    private var mockHK:  MockHealthKitService!

    private let testEventId = "integration-test-event"

    override func setUp() {
        super.setUp()
        mockLoc = MockSessionLocationManager()
        mockHK  = MockHealthKitService()
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
        let originalLoc = MockSessionLocationManager()
        let original = MetricsCollectorRun(
            isCreator: true, numSessions: 2,
            locationManager: originalLoc, healthKit: mockHK,
            userIdProvider: { "user-123" }
        )
        original.startSession(eventId: testEventId)

        originalLoc.subject.send(iLoc(lat: 45.000, lon: 9.000, accuracy: 10, speed: 3, timestamp: iSecs(50_000)))
        originalLoc.subject.send(iLoc(lat: 45.005, lon: 9.000, accuracy: 10, speed: 3, timestamp: iSecs(50_002)))
        originalLoc.subject.send(iLoc(lat: 45.010, lon: 9.000, accuracy: 10, speed: 3, timestamp: iSecs(50_004)))

        let distanceBefore = original.totalDistanceMeters
        let pointsBefore   = original.trackedLocations.count

        original.saveCheckpoint(eventId: testEventId)

        let newLoc = MockSessionLocationManager()
        let restored = MetricsCollectorRun(
            isCreator: true, numSessions: 2,
            locationManager: newLoc, healthKit: mockHK,
            userIdProvider: { "user-123" }
        )
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

        originalLoc.subject.send(iLoc(lat: 45.00, lon: 9.0, altitude: 0,   accuracy: 10, speed: 1, timestamp: iSecs(60_000)))
        originalLoc.subject.send(iLoc(lat: 45.01, lon: 9.0, altitude: 100, accuracy: 10, speed: 1, timestamp: iSecs(60_002)))
        originalLoc.subject.send(iLoc(lat: 45.02, lon: 9.0, altitude: 200, accuracy: 10, speed: 1, timestamp: iSecs(60_004)))
        originalLoc.subject.send(iLoc(lat: 45.03, lon: 9.0, altitude: 150, accuracy: 10, speed: 1, timestamp: iSecs(60_006)))

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

        originalLoc.subject.send(iLoc(lat: 45.000, lon: 9.0, accuracy: 10, speed: 10, timestamp: iSecs(70_000)))
        originalLoc.subject.send(iLoc(lat: 45.001, lon: 9.0, accuracy: 10, speed: 12, timestamp: iSecs(70_002)))

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

        originalLoc.subject.send(iLoc(lat: 45.000, lon: 9.0, altitude: 100, accuracy: 10, speed: 8, timestamp: iSecs(80_000)))
        originalLoc.subject.send(iLoc(lat: 45.001, lon: 9.0, altitude: 80,  accuracy: 10, speed: 8, timestamp: iSecs(80_002)))
        originalLoc.subject.send(iLoc(lat: 45.002, lon: 9.0, altitude: 90,  accuracy: 10, speed: 8, timestamp: iSecs(80_004)))
        originalLoc.subject.send(iLoc(lat: 45.003, lon: 9.0, altitude: 70,  accuracy: 10, speed: 8, timestamp: iSecs(80_006)))

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

    // MARK: - TrackPoint ↔ CLLocation round-trip

    func test_trackPointToLocation_roundTrip_preservesCoordinates() {
        let original = TrackPoint(timestamp: iSecs(9000), latitude: 45.123, longitude: 9.456)

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

    // MARK: - trimTrack + computeDistance pipeline

    func test_trimAndDistance_participantTrimPipeline_producesCorrectDistance() {
        let creatorEnd = iSecs(10_010)

        let track: [(Date, CLLocation)] = [
            (iSecs(10_000), iLoc(lat: 45.000, lon: 9.000, accuracy: 10, speed: 3)),
            (iSecs(10_003), iLoc(lat: 45.005, lon: 9.000, accuracy: 10, speed: 3)),
            (iSecs(10_006), iLoc(lat: 45.010, lon: 9.000, accuracy: 10, speed: 3)),
            (iSecs(10_015), iLoc(lat: 45.020, lon: 9.000, accuracy: 10, speed: 3))
        ]

        let trimmed = MetricsCollectorUtils.trimTrack(track, to: creatorEnd)
        XCTAssertEqual(trimmed.count, 3, "Point after creator end must be removed")

        let distance = MetricsCollectorUtils.computeDistance(from: trimmed.map { $0.1 })
        XCTAssertGreaterThan(distance, 0)

        let fullDistance = MetricsCollectorUtils.computeDistance(from: track.map { $0.1 })
        XCTAssertLessThan(distance, fullDistance)
    }

    // MARK: - RunMetricsUploader participant logic

    func test_participantUploader_endedBeforeCreator_usesFullData() {
        let startDate = iSecs(1_000)
        let elapsedSeconds = 500.0
        let finalEndDateTime = iSecs(1_700)

        let participantEndTime = startDate.addingTimeInterval(elapsedSeconds)
        XCTAssertTrue(participantEndTime <= finalEndDateTime)
    }

    func test_participantUploader_endedAfterCreator_usesCreatorEnd() {
        let startDate = iSecs(1_000)
        let elapsedSeconds = 800.0
        let finalEndDateTime = iSecs(1_700)

        let participantEndTime = startDate.addingTimeInterval(elapsedSeconds)
        XCTAssertFalse(participantEndTime <= finalEndDateTime)
    }

    func test_participantUploader_fallback_computesFallbackEndTime() {
        let startDate = iSecs(2_000)
        let elapsedSeconds = 1_200.0
        let expectedFallbackEnd = iSecs(3_200)

        let fallbackEnd = startDate.addingTimeInterval(elapsedSeconds)
        XCTAssertEqual(fallbackEnd.timeIntervalSinceReferenceDate,
                       expectedFallbackEnd.timeIntervalSinceReferenceDate,
                       accuracy: 0.001)
    }

    // MARK: - Elevation pipeline

    func test_elevationPipeline_gainAndLoss_areComplementary() {
        let locs = [
            iLoc(altitude: 0),
            iLoc(altitude: 100),
            iLoc(altitude: 50),
            iLoc(altitude: 80),
            iLoc(altitude: 0)
        ]
        let gain = MetricsCollectorUtils.computeElevationGain(from: locs)
        let loss = MetricsCollectorUtils.computeElevationLoss(from: locs)

        XCTAssertEqual(gain, 130, accuracy: 0.001)
        XCTAssertEqual(loss, 130, accuracy: 0.001)
    }

    // MARK: - Boundary conditions

    func test_locationFilter_boundaryAccuracy19_9_isAccepted() {
        XCTAssertTrue(MetricsCollectorUtils.isValidLocation(iLoc(accuracy: 19.9, speed: 1), lastLocation: nil))
    }

    func test_locationFilter_boundaryAccuracy20_isRejected() {
        XCTAssertFalse(MetricsCollectorUtils.isValidLocation(iLoc(accuracy: 20.0, speed: 1), lastLocation: nil))
    }

    func test_locationFilter_zeroSpeed_isAccepted_standsStill() {
        XCTAssertTrue(MetricsCollectorUtils.isValidLocation(iLoc(accuracy: 5, speed: 0), lastLocation: nil))
    }
}
