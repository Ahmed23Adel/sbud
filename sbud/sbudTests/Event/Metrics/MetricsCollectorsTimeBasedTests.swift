//
//  MetricsCollectorsTimeBasedTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 11/07/2026.
//


import XCTest
@testable import sbud

@MainActor
final class MetricsCollectorsTimeBasedTests: XCTestCase {

    private var healthKit: MockHealthKitService!

    override func setUp() {
        super.setUp()
        healthKit = MockHealthKitService()
    }

    /// Aspetta che il timer (1s) faccia almeno un tick
    private func waitForTimerTick() async throws {
        try await Task.sleep(nanoseconds: 1_300_000_000)
    }

    // MARK: - Swimming

    func test_swimming_start_setsTrackingAndResets() {
        let sut = MetricsCollectorSwimming(isCreator: true, numSessions: 1,
                                           healthKit: healthKit, userIdProvider: { "u" })
        sut.startSession(eventId: "swim_evt")
        XCTAssertTrue(sut.isTracking)
        XCTAssertEqual(sut.elapsedSeconds, 0)
    }

    func test_swimming_elapsed_countsFromRestoredStartDate() async throws {
        let sut = MetricsCollectorSwimming(isCreator: true, numSessions: 1,
                                           healthKit: healthKit, userIdProvider: { "u" })
        sut.startSession(eventId: "swim_evt")
        // Simuliamo una sessione ripresa: iniziata 100 secondi fa
        sut.restoreStartDate(Date().addingTimeInterval(-100))

        try await waitForTimerTick()

        XCTAssertGreaterThan(sut.elapsedSeconds, 99,
                             "L'elapsed deve ripartire dalla data ripristinata")
    }

    func test_swimming_endWithoutUser_throws_andStopsTracking() async {
        let sut = MetricsCollectorSwimming(isCreator: true, numSessions: 1,
                                           healthKit: healthKit, userIdProvider: { nil })
        sut.startSession(eventId: "swim_evt")
        do {
            try await sut.endSession(event: .fixture(id: "swim_evt"))
            XCTFail("Doveva lanciare profileNotAvailable")
        } catch { }
        XCTAssertFalse(sut.isTracking)
    }

    // MARK: - Tennis

    func test_tennis_start_setsTracking() {
        let sut = MetricsCollectorTennis(isCreator: false, numSessions: 2,
                                         healthKit: healthKit, userIdProvider: { "u" })
        sut.startSession(eventId: "tennis_evt")
        XCTAssertTrue(sut.isTracking)
        XCTAssertEqual(sut.elapsedSeconds, 0)
    }

    func test_tennis_elapsed_advancesWithTimer() async throws {
        let sut = MetricsCollectorTennis(isCreator: true, numSessions: 1,
                                         healthKit: healthKit, userIdProvider: { "u" })
        sut.startSession(eventId: "tennis_evt")

        try await waitForTimerTick()

        XCTAssertGreaterThan(sut.elapsedSeconds, 0.9)
    }

    func test_tennis_endWithoutUser_throws() async {
        let sut = MetricsCollectorTennis(isCreator: true, numSessions: 1,
                                         healthKit: healthKit, userIdProvider: { nil })
        sut.startSession(eventId: "tennis_evt")
        do {
            try await sut.endSession(event: .fixture(id: "tennis_evt"))
            XCTFail("Doveva lanciare")
        } catch { }
        XCTAssertFalse(sut.isTracking)
    }

    // MARK: - Yoga

    func test_yoga_start_setsTracking() {
        let sut = MetricsCollectorYoga(isCreator: true, numSessions: 1,
                                       healthKit: healthKit, userIdProvider: { "u" })
        sut.startSession(eventId: "yoga_evt")
        XCTAssertTrue(sut.isTracking)
    }

    func test_yoga_restoreStartDate_affectsElapsed() async throws {
        let sut = MetricsCollectorYoga(isCreator: true, numSessions: 1,
                                       healthKit: healthKit, userIdProvider: { "u" })
        sut.startSession(eventId: "yoga_evt")
        sut.restoreStartDate(Date().addingTimeInterval(-50))

        try await waitForTimerTick()

        XCTAssertGreaterThan(sut.elapsedSeconds, 49)
    }

    func test_yoga_endWithoutUser_throws() async {
        let sut = MetricsCollectorYoga(isCreator: true, numSessions: 1,
                                       healthKit: healthKit, userIdProvider: { nil })
        sut.startSession(eventId: "yoga_evt")
        do {
            try await sut.endSession(event: .fixture(id: "yoga_evt"))
            XCTFail("Doveva lanciare")
        } catch { }
        XCTAssertFalse(sut.isTracking)
    }
}