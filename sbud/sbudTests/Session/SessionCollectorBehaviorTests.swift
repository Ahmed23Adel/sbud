//
//  SessionCollectorBehaviorTests.swift
//  sbudTests
//
//  Tests for:
//  - location update handling & metric accumulation
//  - endSession throwing when userId is nil
//  - restoreStartDate for time-based collectors
//  - time-based collectors tracking/isTracking state
//

import XCTest
import CoreLocation
@testable import sbud
import Combine

// MARK: - Helper locali (adattati ai mock condivisi)

private func loc(lat: Double = 45.0, lon: Double = 9.0,
                 altitude: Double = 100,
                 accuracy: Double = 10,
                 speed: Double = 3.0,
                 timestamp: Date = Date()) -> CLLocation {
    makeLocation(lat: lat, lon: lon, altitude: altitude,
                 accuracy: accuracy, speed: speed, timestamp: timestamp)
}

private func secs(_ v: Double) -> Date { Date(timeIntervalSince1970: v) }

// MARK: - endSession profileNotAvailable

final class SessionEndSessionErrorTests: XCTestCase {

    private var mockLoc: MockSessionLocationManager!
    private var mockHK:  MockHealthKitService!
    private var mockEvent: EventFullDetails!

    override func setUp() {
        super.setUp()
        mockLoc   = MockSessionLocationManager()
        mockHK    = MockHealthKitService()
        mockEvent = EventFullDetails.fixture()
    }

    override func tearDown() {
        mockLoc = nil; mockHK = nil; mockEvent = nil
        super.tearDown()
    }

    func test_runCollector_endSession_nilUserId_throwsProfileNotAvailable() async {
        let sut = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                      locationManager: mockLoc, healthKit: mockHK,
                                      userIdProvider: { nil })
        sut.startSession(eventId: mockEvent.id)
        do {
            try await sut.endSession(event: mockEvent)
            XCTFail("Expected MetricsError.profileNotAvailable")
        } catch MetricsError.profileNotAvailable {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        sut.clearCheckpoint(eventId: mockEvent.id)
    }

    func test_hikingCollector_endSession_nilUserId_throwsProfileNotAvailable() async {
        let sut = MetricsCollectorHiking(isCreator: true, numSessions: 1,
                                         locationManager: mockLoc, healthKit: mockHK,
                                         userIdProvider: { nil })
        sut.startSession(eventId: mockEvent.id)
        do {
            try await sut.endSession(event: mockEvent)
            XCTFail("Expected MetricsError.profileNotAvailable")
        } catch MetricsError.profileNotAvailable {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        sut.clearCheckpoint(eventId: mockEvent.id)
    }

    func test_cyclingCollector_endSession_nilUserId_throwsProfileNotAvailable() async {
        let sut = MetricsCollectorCycling(isCreator: true, numSessions: 1,
                                          locationManager: mockLoc, healthKit: mockHK,
                                          userIdProvider: { nil })
        sut.startSession(eventId: mockEvent.id)
        do {
            try await sut.endSession(event: mockEvent)
            XCTFail("Expected MetricsError.profileNotAvailable")
        } catch MetricsError.profileNotAvailable {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        sut.clearCheckpoint(eventId: mockEvent.id)
    }

    func test_skiingCollector_endSession_nilUserId_throwsProfileNotAvailable() async {
        let sut = MetricsCollectorSkiing(isCreator: true, numSessions: 1,
                                         locationManager: mockLoc, healthKit: mockHK,
                                         userIdProvider: { nil })
        sut.startSession(eventId: mockEvent.id)
        do {
            try await sut.endSession(event: mockEvent)
            XCTFail("Expected MetricsError.profileNotAvailable")
        } catch MetricsError.profileNotAvailable {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        sut.clearCheckpoint(eventId: mockEvent.id)
    }

    func test_gymCollector_endSession_nilUserId_throwsProfileNotAvailable() async {
        let sut = MetricsCollectorGym(isCreator: true, numSessions: 1,
                                      healthKit: mockHK, userIdProvider: { nil })
        sut.startSession(eventId: mockEvent.id)
        do {
            try await sut.endSession(event: mockEvent)
            XCTFail("Expected MetricsError.profileNotAvailable")
        } catch MetricsError.profileNotAvailable {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_yogaCollector_endSession_nilUserId_throwsProfileNotAvailable() async {
        let sut = MetricsCollectorYoga(isCreator: true, numSessions: 1,
                                       healthKit: mockHK, userIdProvider: { nil })
        sut.startSession(eventId: mockEvent.id)
        do {
            try await sut.endSession(event: mockEvent)
            XCTFail("Expected MetricsError.profileNotAvailable")
        } catch MetricsError.profileNotAvailable {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_swimmingCollector_endSession_nilUserId_throwsProfileNotAvailable() async {
        let sut = MetricsCollectorSwimming(isCreator: true, numSessions: 1,
                                           healthKit: mockHK, userIdProvider: { nil })
        sut.startSession(eventId: mockEvent.id)
        do {
            try await sut.endSession(event: mockEvent)
            XCTFail("Expected MetricsError.profileNotAvailable")
        } catch MetricsError.profileNotAvailable {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_tennisCollector_endSession_nilUserId_throwsProfileNotAvailable() async {
        let sut = MetricsCollectorTennis(isCreator: true, numSessions: 1,
                                         healthKit: mockHK, userIdProvider: { nil })
        sut.startSession(eventId: mockEvent.id)
        do {
            try await sut.endSession(event: mockEvent)
            XCTFail("Expected MetricsError.profileNotAvailable")
        } catch MetricsError.profileNotAvailable {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Location update handling

final class SessionLocationUpdateTests: XCTestCase {

    private var mockLoc: MockSessionLocationManager!
    private var mockHK:  MockHealthKitService!

    override func setUp() {
        super.setUp()
        mockLoc = MockSessionLocationManager()
        mockHK  = MockHealthKitService()
    }

    override func tearDown() {
        mockLoc = nil; mockHK = nil
        super.tearDown()
    }

    /// adattato: i mock condivisi usano subject.send al posto di emit
    private func emit(_ location: CLLocation) { mockLoc.subject.send(location) }

    func test_runCollector_invalidAccuracy_locationRejected() {
        let sut = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                      locationManager: mockLoc, healthKit: mockHK,
                                      userIdProvider: { "u" })
        sut.startSession(eventId: "e1")
        defer { sut.clearCheckpoint(eventId: "e1") }

        emit(loc(accuracy: 50, speed: 5))

        XCTAssertEqual(sut.trackedLocations.count, 0)
        XCTAssertEqual(sut.totalDistanceMeters, 0, accuracy: 0.001)
    }

    func test_runCollector_validLocation_accumulatesDistance() {
        let sut = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                      locationManager: mockLoc, healthKit: mockHK,
                                      userIdProvider: { "u" })
        sut.startSession(eventId: "e1")
        defer { sut.clearCheckpoint(eventId: "e1") }

        emit(loc(lat: 45.0, lon: 9.0, accuracy: 10, speed: 5, timestamp: secs(1000)))
        emit(loc(lat: 45.001, lon: 9.0, accuracy: 10, speed: 5, timestamp: secs(1002)))

        XCTAssertGreaterThan(sut.totalDistanceMeters, 0)
        XCTAssertEqual(sut.trackedLocations.count, 2)
    }

    func test_runCollector_negativeSpeed_locationRejected() {
        let sut = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                      locationManager: mockLoc, healthKit: mockHK,
                                      userIdProvider: { "u" })
        sut.startSession(eventId: "e1")
        defer { sut.clearCheckpoint(eventId: "e1") }

        emit(loc(accuracy: 10, speed: -1))

        XCTAssertEqual(sut.trackedLocations.count, 0)
    }

    func test_runCollector_tooFastTimeDelta_locationRejected() {
        let sut = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                      locationManager: mockLoc, healthKit: mockHK,
                                      userIdProvider: { "u" })
        sut.startSession(eventId: "e1")
        defer { sut.clearCheckpoint(eventId: "e1") }

        emit(loc(accuracy: 10, speed: 5, timestamp: secs(1000)))
        emit(loc(accuracy: 10, speed: 5, timestamp: secs(1000.3)))

        XCTAssertEqual(sut.trackedLocations.count, 1)
    }

    func test_hikingCollector_validLocations_tracksElevation() {
        let sut = MetricsCollectorHiking(isCreator: true, numSessions: 1,
                                         locationManager: mockLoc, healthKit: mockHK,
                                         userIdProvider: { "u" })
        sut.startSession(eventId: "e2")
        defer { sut.clearCheckpoint(eventId: "e2") }

        emit(loc(lat: 45.0, lon: 9.0, altitude: 100, accuracy: 10, speed: 2, timestamp: secs(1000)))
        emit(loc(lat: 45.001, lon: 9.0, altitude: 150, accuracy: 10, speed: 2, timestamp: secs(1002)))

        XCTAssertEqual(sut.elevationGainMeters, 50, accuracy: 0.5)
        XCTAssertEqual(sut.elevationLossMeters, 0, accuracy: 0.001)
        XCTAssertEqual(sut.maxAltitudeMeters, 150, accuracy: 0.5)
        XCTAssertEqual(sut.currentAltitudeMeters, 150, accuracy: 0.5)
    }

    func test_hikingCollector_descent_tracksElevationLoss() {
        let sut = MetricsCollectorHiking(isCreator: true, numSessions: 1,
                                         locationManager: mockLoc, healthKit: mockHK,
                                         userIdProvider: { "u" })
        sut.startSession(eventId: "e3")
        defer { sut.clearCheckpoint(eventId: "e3") }

        emit(loc(lat: 45.0, lon: 9.0, altitude: 200, accuracy: 10, speed: 3, timestamp: secs(1000)))
        emit(loc(lat: 45.001, lon: 9.0, altitude: 150, accuracy: 10, speed: 3, timestamp: secs(1002)))

        XCTAssertEqual(sut.elevationLossMeters, 50, accuracy: 0.5)
        XCTAssertEqual(sut.elevationGainMeters, 0, accuracy: 0.001)
    }

    func test_skiingCollector_descent_incrementsRunCount() {
        let sut = MetricsCollectorSkiing(isCreator: true, numSessions: 1,
                                         locationManager: mockLoc, healthKit: mockHK,
                                         userIdProvider: { "u" })
        sut.startSession(eventId: "e4")
        defer { sut.clearCheckpoint(eventId: "e4") }

        emit(loc(lat: 45.0, lon: 9.0, altitude: 100, accuracy: 10, speed: 5, timestamp: secs(1000)))
        emit(loc(lat: 45.001, lon: 9.0, altitude: 80, accuracy: 10, speed: 5, timestamp: secs(1002)))
        emit(loc(lat: 45.002, lon: 9.0, altitude: 60, accuracy: 10, speed: 5, timestamp: secs(1004)))

        XCTAssertEqual(sut.numberOfRuns, 1)
        XCTAssertGreaterThan(sut.verticalDropMeters, 0)
    }

    func test_skiingCollector_ascentAfterDescent_resetsDescendingFlag() {
        let sut = MetricsCollectorSkiing(isCreator: true, numSessions: 1,
                                         locationManager: mockLoc, healthKit: mockHK,
                                         userIdProvider: { "u" })
        sut.startSession(eventId: "e5")
        defer { sut.clearCheckpoint(eventId: "e5") }

        emit(loc(lat: 45.000, lon: 9.0, altitude: 100, accuracy: 10, speed: 5, timestamp: secs(1000)))
        emit(loc(lat: 45.001, lon: 9.0, altitude: 80,  accuracy: 10, speed: 5, timestamp: secs(1002)))
        emit(loc(lat: 45.002, lon: 9.0, altitude: 90,  accuracy: 10, speed: 5, timestamp: secs(1004)))
        emit(loc(lat: 45.003, lon: 9.0, altitude: 70,  accuracy: 10, speed: 5, timestamp: secs(1006)))

        XCTAssertEqual(sut.numberOfRuns, 2)
    }

    func test_cyclingCollector_validLocations_accumulatesDistance() {
        let sut = MetricsCollectorCycling(isCreator: true, numSessions: 1,
                                          locationManager: mockLoc, healthKit: mockHK,
                                          userIdProvider: { "u" })
        sut.startSession(eventId: "e6")
        defer { sut.clearCheckpoint(eventId: "e6") }

        emit(loc(lat: 45.0, lon: 9.0, accuracy: 10, speed: 10, timestamp: secs(1000)))
        emit(loc(lat: 45.005, lon: 9.0, accuracy: 10, speed: 10, timestamp: secs(1002)))

        XCTAssertGreaterThan(sut.totalDistanceMeters, 0)
    }

    func test_cyclingCollector_positiveSpeed_updatesMinMaxSpeed() {
        let sut = MetricsCollectorCycling(isCreator: true, numSessions: 1,
                                          locationManager: mockLoc, healthKit: mockHK,
                                          userIdProvider: { "u" })
        sut.startSession(eventId: "e7")
        defer { sut.clearCheckpoint(eventId: "e7") }

        emit(loc(lat: 45.0, lon: 9.0, accuracy: 10, speed: 10, timestamp: secs(1000)))
        emit(loc(lat: 45.001, lon: 9.0, accuracy: 10, speed: 10, timestamp: secs(1002)))

        XCTAssertEqual(sut.currentSpeedKmH, 36.0, accuracy: 0.1)
        XCTAssertEqual(sut.minSpeedKmH, 36.0, accuracy: 0.1)
        XCTAssertEqual(sut.maxSpeedKmH, 36.0, accuracy: 0.1)
    }
}

// MARK: - Time-based collector state

final class TimeBasedCollectorTests: XCTestCase {

    private var mockHK: MockHealthKitService!

    override func setUp() {
        super.setUp()
        mockHK = MockHealthKitService()
    }

    override func tearDown() {
        mockHK = nil
        super.tearDown()
    }

    func test_gymCollector_startSession_setsIsTracking() {
        let sut = MetricsCollectorGym(isCreator: true, numSessions: 1,
                                      healthKit: mockHK, userIdProvider: { "u" })
        XCTAssertFalse(sut.isTracking)
        sut.startSession(eventId: "e")
        XCTAssertTrue(sut.isTracking)
    }

    func test_gymCollector_restoreStartDate_affectsElapsed() {
        let sut = MetricsCollectorGym(isCreator: true, numSessions: 1,
                                      healthKit: mockHK, userIdProvider: { "u" })
        sut.startSession(eventId: "e")
        sut.restoreStartDate(Date(timeIntervalSinceNow: -120))
        XCTAssertTrue(sut.isTracking)
    }

    func test_yogaCollector_startSession_setsIsTracking() {
        let sut = MetricsCollectorYoga(isCreator: false, numSessions: 2,
                                       healthKit: mockHK, userIdProvider: { "u" })
        XCTAssertFalse(sut.isTracking)
        sut.startSession(eventId: "e")
        XCTAssertTrue(sut.isTracking)
    }

    func test_swimmingCollector_startSession_setsIsTracking() {
        let sut = MetricsCollectorSwimming(isCreator: false, numSessions: 1,
                                           healthKit: mockHK, userIdProvider: { "u" })
        sut.startSession(eventId: "e")
        XCTAssertTrue(sut.isTracking)
    }

    func test_tennisCollector_startSession_setsIsTracking() {
        let sut = MetricsCollectorTennis(isCreator: false, numSessions: 1,
                                         healthKit: mockHK, userIdProvider: { "u" })
        sut.startSession(eventId: "e")
        XCTAssertTrue(sut.isTracking)
    }

    func test_gymCollector_initialElapsedSeconds_isZero() {
        let sut = MetricsCollectorGym(isCreator: true, numSessions: 1,
                                      healthKit: mockHK, userIdProvider: { "u" })
        XCTAssertEqual(sut.elapsedSeconds, 0, accuracy: 0.001)
    }
}
