//
//  MetricsCollectorSkiingTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 11/07/2026.
//


import XCTest
import CoreLocation
import Combine
@testable import sbud

// MARK: - Skiing

@MainActor
final class MetricsCollectorSkiingTests: XCTestCase {

    private var location: MockSessionLocationManager!
    private var sut: MetricsCollectorSkiing!
    private let eventId = "ski_evt_test"
    private let t0 = Date()

    override func setUp() {
        super.setUp()
        location = MockSessionLocationManager()
        sut = MetricsCollectorSkiing(isCreator: true, numSessions: 1,
                                     locationManager: location,
                                     healthKit: MockHealthKitService(),
                                     userIdProvider: { "ski_user" })
        sut.clearCheckpoint(eventId: eventId)
    }

    override func tearDown() {
        sut.clearCheckpoint(eventId: eventId)
        sut = nil; location = nil
        super.tearDown()
    }

    private func push(lat: Double, altitude: Double, speed: Double = 10, seconds: Double) {
        location.subject.send(makeLocation(lat: lat, lon: 9, altitude: altitude,
                                           speed: speed, timestamp: t0.addingTimeInterval(seconds)))
    }

    func test_start_setsTracking() {
        sut.startSession(eventId: eventId)
        XCTAssertTrue(sut.isTracking)
        XCTAssertTrue(location.startUpdatingCalled)
    }

    func test_descent_accumulatesVerticalDrop_andCountsOneRun() {
        sut.startSession(eventId: eventId)

        push(lat: 45.000, altitude: 2000, seconds: 0)
        push(lat: 45.001, altitude: 1950, seconds: 10)
        push(lat: 45.002, altitude: 1900, seconds: 20)

        XCTAssertEqual(sut.verticalDropMeters, 100, accuracy: 0.01)
        XCTAssertEqual(sut.numberOfRuns, 1, "Una discesa continua = 1 run")
        XCTAssertEqual(sut.elevationGainMeters, 0)
    }

    func test_twoDescents_separatedByLift_countTwoRuns() {
        sut.startSession(eventId: eventId)

        push(lat: 45.000, altitude: 2000, seconds: 0)
        push(lat: 45.001, altitude: 1900, seconds: 10)  // run 1
        push(lat: 45.002, altitude: 1980, seconds: 20)  // risalita (skilift)
        push(lat: 45.003, altitude: 1880, seconds: 30)  // run 2

        XCTAssertEqual(sut.numberOfRuns, 2)
        XCTAssertEqual(sut.verticalDropMeters, 200, accuracy: 0.01)
        XCTAssertEqual(sut.elevationGainMeters, 80, accuracy: 0.01)
    }

    func test_maxSpeed_tracked() {
        sut.startSession(eventId: eventId)

        push(lat: 45.000, altitude: 2000, speed: 5, seconds: 0)
        push(lat: 45.001, altitude: 1950, speed: 15, seconds: 10) // 54 km/h
        push(lat: 45.002, altitude: 1900, speed: 8, seconds: 20)

        XCTAssertEqual(sut.maxSpeedKmH, 54, accuracy: 0.1)
        XCTAssertEqual(sut.currentSpeedKmH, 28.8, accuracy: 0.1)
    }

    func test_split_after1000m_recordsSpeed() {
        sut.startSession(eventId: eventId)
        for i in 0...10 {
            push(lat: 45.0 + Double(i) * 0.001, altitude: 2000 - Double(i * 10),
                 seconds: Double(i) * 60)
        }
        XCTAssertEqual(sut.splits.count, 1)
        XCTAssertGreaterThan(sut.splits.first?.speedKmH ?? 0, 0)
    }

    func test_checkpoint_roundTrip_restoresSkiingMetrics() {
        sut.startSession(eventId: eventId)
        push(lat: 45.000, altitude: 2000, seconds: 0)
        push(lat: 45.001, altitude: 1900, seconds: 10)
        sut.saveCheckpoint(eventId: eventId)

        let restored = MetricsCollectorSkiing(isCreator: true, numSessions: 1,
                                              locationManager: MockSessionLocationManager(),
                                              healthKit: MockHealthKitService(),
                                              userIdProvider: { "ski_user" })
        XCTAssertTrue(restored.restoreCheckpoint(eventId: eventId))
        XCTAssertEqual(restored.verticalDropMeters, 100, accuracy: 0.01)
        XCTAssertEqual(restored.numberOfRuns, 1)
        XCTAssertEqual(restored.trackedLocations.count, 2)
    }

    func test_endSession_withoutUser_throws() async {
        let noUser = MetricsCollectorSkiing(isCreator: true, numSessions: 1,
                                            locationManager: location,
                                            healthKit: MockHealthKitService(),
                                            userIdProvider: { nil })
        noUser.startSession(eventId: eventId)
        do {
            try await noUser.endSession(event: .fixture(id: eventId))
            XCTFail("Doveva lanciare")
        } catch { }
        XCTAssertFalse(noUser.isTracking)
        noUser.clearCheckpoint(eventId: eventId)
    }
}

// MARK: - Cycling

@MainActor
final class MetricsCollectorCyclingTests: XCTestCase {

    private var location: MockSessionLocationManager!
    private var sut: MetricsCollectorCycling!
    private let eventId = "cycle_evt_test"
    private let t0 = Date()

    override func setUp() {
        super.setUp()
        location = MockSessionLocationManager()
        sut = MetricsCollectorCycling(isCreator: true, numSessions: 1,
                                      locationManager: location,
                                      healthKit: MockHealthKitService(),
                                      userIdProvider: { "cycle_user" })
        sut.clearCheckpoint(eventId: eventId)
    }

    override func tearDown() {
        sut.clearCheckpoint(eventId: eventId)
        sut = nil; location = nil
        super.tearDown()
    }

    private func push(lat: Double, altitude: Double = 100, speed: Double = 8, seconds: Double) {
        location.subject.send(makeLocation(lat: lat, lon: 9, altitude: altitude,
                                           speed: speed, timestamp: t0.addingTimeInterval(seconds)))
    }

    func test_distance_accumulates() {
        sut.startSession(eventId: eventId)
        push(lat: 45.000, seconds: 0)
        push(lat: 45.001, seconds: 10)
        push(lat: 45.002, seconds: 20)
        XCTAssertEqual(sut.totalDistanceMeters, 222, accuracy: 5)
    }

    func test_minAndMaxSpeed_tracked() {
        sut.startSession(eventId: eventId)
        push(lat: 45.000, speed: 99, seconds: 0)  // primo punto: solo riferimento, speed ignorata
        push(lat: 45.001, speed: 5, seconds: 10)  // 18 km/h
        push(lat: 45.002, speed: 12, seconds: 20) // 43.2
        push(lat: 45.003, speed: 7, seconds: 30)  // 25.2

        XCTAssertEqual(sut.maxSpeedKmH, 43.2, accuracy: 0.1)
        XCTAssertEqual(sut.minSpeedKmH, 18, accuracy: 0.1)
    }

    func test_elevation_onlyGainCounted() {
        sut.startSession(eventId: eventId)
        push(lat: 45.000, altitude: 100, seconds: 0)
        push(lat: 45.001, altitude: 130, seconds: 10)
        push(lat: 45.002, altitude: 110, seconds: 20)

        XCTAssertEqual(sut.elevationGainMeters, 30, accuracy: 0.01,
                       "In bici si conta solo il dislivello positivo")
    }

    func test_split_recordsSpeedKmH() {
        sut.startSession(eventId: eventId)
        for i in 0...10 {
            push(lat: 45.0 + Double(i) * 0.001, seconds: Double(i) * 30)
        }
        XCTAssertEqual(sut.splits.count, 1)
        XCTAssertGreaterThan(sut.splits.first?.speedKmH ?? 0, 0)
    }

    func test_splitForCycling_formattedPace() {
        let split = SplitForCycling(number: 1, paceInMinPerKm: 4.5, speedKmH: 13.3)
        XCTAssertEqual(split.formattedPace, "4'30\"/km")
    }

    func test_checkpoint_roundTrip() {
        sut.startSession(eventId: eventId)
        push(lat: 45.000, speed: 10, seconds: 0)
        push(lat: 45.001, speed: 10, seconds: 10)
        sut.saveCheckpoint(eventId: eventId)

        let restored = MetricsCollectorCycling(isCreator: true, numSessions: 1,
                                               locationManager: MockSessionLocationManager(),
                                               healthKit: MockHealthKitService(),
                                               userIdProvider: { "cycle_user" })
        XCTAssertTrue(restored.restoreCheckpoint(eventId: eventId))
        XCTAssertEqual(restored.totalDistanceMeters, sut.totalDistanceMeters, accuracy: 0.01)
        XCTAssertEqual(restored.maxSpeedKmH, 36, accuracy: 0.1)
    }
}

// MARK: - Hiking

@MainActor
final class MetricsCollectorHikingTests: XCTestCase {

    private var location: MockSessionLocationManager!
    private var sut: MetricsCollectorHiking!
    private let eventId = "hike_evt_test"
    private let t0 = Date()

    override func setUp() {
        super.setUp()
        location = MockSessionLocationManager()
        sut = MetricsCollectorHiking(isCreator: true, numSessions: 1,
                                     locationManager: location,
                                     healthKit: MockHealthKitService(),
                                     userIdProvider: { "hike_user" })
        sut.clearCheckpoint(eventId: eventId)
    }

    override func tearDown() {
        sut.clearCheckpoint(eventId: eventId)
        sut = nil; location = nil
        super.tearDown()
    }

    private func push(lat: Double, altitude: Double, speed: Double = 1.5, seconds: Double) {
        location.subject.send(makeLocation(lat: lat, lon: 9, altitude: altitude,
                                           speed: speed, timestamp: t0.addingTimeInterval(seconds)))
    }

    func test_altitude_currentAndMaxTracked() {
        sut.startSession(eventId: eventId)
        push(lat: 45.000, altitude: 500, seconds: 0)
        push(lat: 45.001, altitude: 800, seconds: 10)
        push(lat: 45.002, altitude: 650, seconds: 20)

        XCTAssertEqual(sut.currentAltitudeMeters, 650)
        XCTAssertEqual(sut.maxAltitudeMeters, 800)
    }

    func test_elevation_gainAndLossSeparated() {
        sut.startSession(eventId: eventId)
        push(lat: 45.000, altitude: 500, seconds: 0)
        push(lat: 45.001, altitude: 700, seconds: 10)  // +200
        push(lat: 45.002, altitude: 600, seconds: 20)  // -100
        push(lat: 45.003, altitude: 750, seconds: 30)  // +150

        XCTAssertEqual(sut.elevationGainMeters, 350, accuracy: 0.01)
        XCTAssertEqual(sut.elevationLossMeters, 100, accuracy: 0.01)
    }

    func test_split_recordsPaceMinPerKm() {
        sut.startSession(eventId: eventId)
        for i in 0...10 {
            push(lat: 45.0 + Double(i) * 0.001, altitude: 500, seconds: Double(i) * 120)
        }
        XCTAssertEqual(sut.splits.count, 1)
        XCTAssertGreaterThan(sut.splits.first?.paceMinPerKm ?? 0, 0)
    }

    func test_checkpoint_roundTrip_restoresAltitudes() {
        sut.startSession(eventId: eventId)
        push(lat: 45.000, altitude: 500, seconds: 0)
        push(lat: 45.001, altitude: 800, seconds: 10)
        sut.saveCheckpoint(eventId: eventId)

        let restored = MetricsCollectorHiking(isCreator: true, numSessions: 1,
                                              locationManager: MockSessionLocationManager(),
                                              healthKit: MockHealthKitService(),
                                              userIdProvider: { "hike_user" })
        XCTAssertTrue(restored.restoreCheckpoint(eventId: eventId))
        XCTAssertEqual(restored.maxAltitudeMeters, 800)
        XCTAssertEqual(restored.elevationGainMeters, 300, accuracy: 0.01)
    }

    func test_locationsIgnored_whenNotTracking() {
        push(lat: 45, altitude: 500, seconds: 0)
        XCTAssertTrue(sut.trackedLocations.isEmpty)
    }
}
