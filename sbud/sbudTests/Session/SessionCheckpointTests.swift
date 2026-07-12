//
//  SessionCheckpointTests.swift
//  sbudTests
//
//  Tests for checkpoint save / restore across all four GPS collectors.
//  Uses real UserDefaults.standard but cleans up with clearCheckpoint in tearDown.
//

import XCTest
import CoreLocation
@testable import sbud

final class SessionCheckpointTests: XCTestCase {

    private var mockLoc: MockSessionLocationManager!
    private var mockHK:  MockHealthKitService!

    override func setUp() {
        super.setUp()
        mockLoc = MockSessionLocationManager()
        mockHK  = MockHealthKitService()
    }

    override func tearDown() {
        let eventId = "test-event-checkpoint"
        MetricsCollectorRun(isCreator: true, numSessions: 1,
                            locationManager: MockSessionLocationManager(),
                            healthKit: MockHealthKitService(),
                            userIdProvider: { nil })
            .clearCheckpoint(eventId: eventId)

        MetricsCollectorHiking(isCreator: true, numSessions: 1,
                               locationManager: MockSessionLocationManager(),
                               healthKit: MockHealthKitService(),
                               userIdProvider: { nil })
            .clearCheckpoint(eventId: eventId)

        MetricsCollectorCycling(isCreator: true, numSessions: 1,
                                locationManager: MockSessionLocationManager(),
                                healthKit: MockHealthKitService(),
                                userIdProvider: { nil })
            .clearCheckpoint(eventId: eventId)

        MetricsCollectorSkiing(isCreator: true, numSessions: 1,
                               locationManager: MockSessionLocationManager(),
                               healthKit: MockHealthKitService(),
                               userIdProvider: { nil })
            .clearCheckpoint(eventId: eventId)

        mockLoc = nil
        mockHK  = nil
        super.tearDown()
    }

    // MARK: - Run

    func test_runCheckpoint_saveAndRestore_preservesDistance() {
        let eventId = "test-event-checkpoint"

        let writer = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                         locationManager: mockLoc,
                                         healthKit: mockHK,
                                         userIdProvider: { "u1" })
        writer.startSession(eventId: eventId)
        writer.totalDistanceMeters = 2345.6
        writer.elapsedSeconds = 720
        writer.minPace = 4.2
        writer.maxPace = 6.8
        writer.splits = [Split(number: 1, paceInMinPerKm: 5.1)]
        writer.saveCheckpoint(eventId: eventId)

        let reader = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                         locationManager: MockSessionLocationManager(),
                                         healthKit: MockHealthKitService(),
                                         userIdProvider: { "u1" })
        let restored = reader.restoreCheckpoint(eventId: eventId)

        XCTAssertTrue(restored)
        XCTAssertEqual(reader.totalDistanceMeters, 2345.6, accuracy: 0.001)
        XCTAssertEqual(reader.elapsedSeconds, 720, accuracy: 0.001)
        XCTAssertEqual(reader.minPace, 4.2, accuracy: 0.001)
        XCTAssertEqual(reader.maxPace, 6.8, accuracy: 0.001)
        XCTAssertEqual(reader.splits.count, 1)
        if reader.splits.count == 1 {
            XCTAssertEqual(reader.splits[0].paceInMinPerKm, 5.1, accuracy: 0.001)
        }

        writer.clearCheckpoint(eventId: eventId)
    }

    func test_runCheckpoint_restoreWithNoSavedData_returnsFalse() {
        let eventId = "test-event-checkpoint-nosave"
        let sut = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                      locationManager: mockLoc,
                                      healthKit: mockHK,
                                      userIdProvider: { "u1" })
        XCTAssertFalse(sut.restoreCheckpoint(eventId: eventId))
    }

    func test_runCheckpoint_clearRemovesData() {
        let eventId = "test-event-checkpoint"
        let sut = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                      locationManager: mockLoc,
                                      healthKit: mockHK,
                                      userIdProvider: { "u1" })
        sut.startSession(eventId: eventId)
        sut.saveCheckpoint(eventId: eventId)
        sut.clearCheckpoint(eventId: eventId)

        let reader = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                         locationManager: MockSessionLocationManager(),
                                         healthKit: MockHealthKitService(),
                                         userIdProvider: { "u1" })
        XCTAssertFalse(reader.restoreCheckpoint(eventId: eventId))
    }

    func test_runCheckpoint_saveAndRestore_preservesSplitsOrder() {
        let eventId = "test-event-checkpoint"
        let writer = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                         locationManager: mockLoc,
                                         healthKit: mockHK,
                                         userIdProvider: { "u1" })
        writer.startSession(eventId: eventId)
        writer.splits = [
            Split(number: 1, paceInMinPerKm: 5.0),
            Split(number: 2, paceInMinPerKm: 4.8),
            Split(number: 3, paceInMinPerKm: 5.2)
        ]
        writer.saveCheckpoint(eventId: eventId)

        let reader = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                         locationManager: MockSessionLocationManager(),
                                         healthKit: MockHealthKitService(),
                                         userIdProvider: { "u1" })
        _ = reader.restoreCheckpoint(eventId: eventId)

        XCTAssertEqual(reader.splits.count, 3)
        guard reader.splits.count == 3 else { return }
        XCTAssertEqual(reader.splits[0].number, 1)
        XCTAssertEqual(reader.splits[1].number, 2)
        XCTAssertEqual(reader.splits[2].number, 3)
        writer.clearCheckpoint(eventId: eventId)
    }

    func test_runCheckpoint_saveAndRestore_preservesTrackPoints() {
        let eventId = "test-event-checkpoint"
        let writer = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                         locationManager: mockLoc,
                                         healthKit: mockHK,
                                         userIdProvider: { "u1" })
        writer.startSession(eventId: eventId)

        // Adattato: usa l'helper makeLocation dei tuoi mock condivisi
        let t = Date(timeIntervalSince1970: 50_000)
        writer.trackedLocations = [(t, makeLocation(lat: 45.0, lon: 9.0, timestamp: t))]
        writer.saveCheckpoint(eventId: eventId)

        let reader = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                         locationManager: MockSessionLocationManager(),
                                         healthKit: MockHealthKitService(),
                                         userIdProvider: { "u1" })
        _ = reader.restoreCheckpoint(eventId: eventId)

        XCTAssertEqual(reader.trackedLocations.count, 1)
        XCTAssertEqual(reader.trackedLocations[0].1.coordinate.latitude, 45.0, accuracy: 0.0001)

        writer.clearCheckpoint(eventId: eventId)
    }

    // MARK: - Hiking

    func test_hikingCheckpoint_saveAndRestore_preservesElevation() {
        let eventId = "test-event-checkpoint"
        let writer = MetricsCollectorHiking(isCreator: true, numSessions: 1,
                                            locationManager: mockLoc,
                                            healthKit: mockHK,
                                            userIdProvider: { "u1" })
        writer.startSession(eventId: eventId)
        writer.elevationGainMeters = 320.0
        writer.elevationLossMeters = 80.0
        writer.maxAltitudeMeters = 1750.0
        writer.totalDistanceMeters = 5000
        writer.saveCheckpoint(eventId: eventId)

        let reader = MetricsCollectorHiking(isCreator: true, numSessions: 1,
                                            locationManager: MockSessionLocationManager(),
                                            healthKit: MockHealthKitService(),
                                            userIdProvider: { "u1" })
        XCTAssertTrue(reader.restoreCheckpoint(eventId: eventId))
        XCTAssertEqual(reader.elevationGainMeters, 320.0, accuracy: 0.001)
        XCTAssertEqual(reader.elevationLossMeters, 80.0, accuracy: 0.001)
        XCTAssertEqual(reader.maxAltitudeMeters, 1750.0, accuracy: 0.001)

        writer.clearCheckpoint(eventId: eventId)
    }

    func test_hikingCheckpoint_noSavedData_returnsFalse() {
        let sut = MetricsCollectorHiking(isCreator: true, numSessions: 1,
                                         locationManager: mockLoc,
                                         healthKit: mockHK,
                                         userIdProvider: { "u1" })
        XCTAssertFalse(sut.restoreCheckpoint(eventId: "no-such-event"))
    }

    // MARK: - Cycling

    func test_cyclingCheckpoint_saveAndRestore_preservesSpeedBounds() {
        let eventId = "test-event-checkpoint"
        let writer = MetricsCollectorCycling(isCreator: true, numSessions: 1,
                                             locationManager: mockLoc,
                                             healthKit: mockHK,
                                             userIdProvider: { "u1" })
        writer.startSession(eventId: eventId)
        writer.minSpeedKmH = 15.0
        writer.maxSpeedKmH = 48.0
        writer.elevationGainMeters = 120
        writer.totalDistanceMeters = 10000
        writer.saveCheckpoint(eventId: eventId)

        let reader = MetricsCollectorCycling(isCreator: true, numSessions: 1,
                                             locationManager: MockSessionLocationManager(),
                                             healthKit: MockHealthKitService(),
                                             userIdProvider: { "u1" })
        XCTAssertTrue(reader.restoreCheckpoint(eventId: eventId))
        XCTAssertEqual(reader.minSpeedKmH, 15.0, accuracy: 0.001)
        XCTAssertEqual(reader.maxSpeedKmH, 48.0, accuracy: 0.001)

        writer.clearCheckpoint(eventId: eventId)
    }

    // MARK: - Skiing

    func test_skiingCheckpoint_saveAndRestore_preservesRunsAndDrop() {
        let eventId = "test-event-checkpoint"
        let writer = MetricsCollectorSkiing(isCreator: true, numSessions: 1,
                                            locationManager: mockLoc,
                                            healthKit: mockHK,
                                            userIdProvider: { "u1" })
        writer.startSession(eventId: eventId)
        writer.numberOfRuns = 5
        writer.verticalDropMeters = 1200
        writer.maxSpeedKmH = 95.0
        writer.saveCheckpoint(eventId: eventId)

        let reader = MetricsCollectorSkiing(isCreator: true, numSessions: 1,
                                            locationManager: MockSessionLocationManager(),
                                            healthKit: MockHealthKitService(),
                                            userIdProvider: { "u1" })
        XCTAssertTrue(reader.restoreCheckpoint(eventId: eventId))
        XCTAssertEqual(reader.numberOfRuns, 5)
        XCTAssertEqual(reader.verticalDropMeters, 1200, accuracy: 0.001)
        XCTAssertEqual(reader.maxSpeedKmH, 95.0, accuracy: 0.001)

        writer.clearCheckpoint(eventId: eventId)
    }

    // MARK: - Memory leaks

    func test_runCollector_noMemoryLeak() {
        var sut: MetricsCollectorRun? = MetricsCollectorRun(
            isCreator: true, numSessions: 1,
            locationManager: mockLoc,
            healthKit: mockHK,
            userIdProvider: { "u" }
        )
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, "MetricsCollectorRun leaked")
        }
        sut = nil
    }

    func test_hikingCollector_noMemoryLeak() {
        var sut: MetricsCollectorHiking? = MetricsCollectorHiking(
            isCreator: false, numSessions: 2,
            locationManager: mockLoc,
            healthKit: mockHK,
            userIdProvider: { "u" }
        )
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, "MetricsCollectorHiking leaked")
        }
        sut = nil
    }
}
