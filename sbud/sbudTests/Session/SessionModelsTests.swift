//
//  SessionModelsTests.swift
//  sbudTests
//
//  Tests for Codable models, Split formatting, TrackPoint, Snapshots,
//  PendingMetricsUpload, and checkpointKey generation.
//

import XCTest
import CoreLocation
@testable import sbud

final class SessionModelsTests: XCTestCase {

    // MARK: - TrackPoint Codable

    func test_trackPoint_codableRoundTrip_preservesAllFields() throws {
        let t = Date.seconds(9999)
        let original = TrackPoint(timestamp: t, latitude: 45.464, longitude: 9.188)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TrackPoint.self, from: data)

        XCTAssertEqual(decoded.timestamp.timeIntervalSinceReferenceDate,
                       original.timestamp.timeIntervalSinceReferenceDate,
                       accuracy: 0.001)
        XCTAssertEqual(decoded.latitude,  original.latitude,  accuracy: 0.000001)
        XCTAssertEqual(decoded.longitude, original.longitude, accuracy: 0.000001)
    }

    func test_trackPoint_codable_negativeCoordinates() throws {
        let original = TrackPoint(timestamp: Date(), latitude: -33.8688, longitude: 151.2093)
        let decoded = try JSONDecoder().decode(TrackPoint.self, from: JSONEncoder().encode(original))
        XCTAssertEqual(decoded.latitude,  -33.8688, accuracy: 0.00001)
        XCTAssertEqual(decoded.longitude, 151.2093, accuracy: 0.00001)
    }

    // MARK: - MetricsCreatorType Codable

    func test_metricsCreatorType_creator_rawValue() {
        XCTAssertEqual(MetricsCreatorType.creator.rawValue, "Creator")
    }

    func test_metricsCreatorType_normalParticipant_rawValue() {
        XCTAssertEqual(MetricsCreatorType.normalParticipant.rawValue, "Normal Participant")
    }

    func test_metricsCreatorType_codableRoundTrip() throws {
        let data = try JSONEncoder().encode(MetricsCreatorType.normalParticipant)
        let decoded = try JSONDecoder().decode(MetricsCreatorType.self, from: data)
        XCTAssertEqual(decoded, .normalParticipant)
    }

    // MARK: - Split

    func test_split_formatted_exactMinutes() {
        let split = Split(number: 1, paceInMinPerKm: 5.0)
        XCTAssertEqual(split.formatted, "5'00\"/km")
    }

    func test_split_formatted_halfMinute() {
        let split = Split(number: 1, paceInMinPerKm: 5.5)
        XCTAssertEqual(split.formatted, "5'30\"/km")
    }

    func test_split_formatted_singleDigitSeconds_zeropads() {
        // 4 min 45 sec — 4.75 is exactly representable in binary floating point
        let split = Split(number: 1, paceInMinPerKm: 4.75)
        XCTAssertEqual(split.formatted, "4'45\"/km")
    }

    func test_split_formatted_zeroPace() {
        let split = Split(number: 1, paceInMinPerKm: 0.0)
        XCTAssertEqual(split.formatted, "0'00\"/km")
    }

    func test_split_formatted_largePace() {
        let split = Split(number: 1, paceInMinPerKm: 12.0)
        XCTAssertEqual(split.formatted, "12'00\"/km")
    }

    func test_split_codableRoundTrip_preservesNumberAndPace() throws {
        let original = Split(number: 3, paceInMinPerKm: 4.75)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Split.self, from: data)
        XCTAssertEqual(decoded.number, 3)
        XCTAssertEqual(decoded.paceInMinPerKm, 4.75, accuracy: 0.0001)
    }

    // MARK: - SplitForCycling

    func test_splitForCycling_formattedPace_zeroPace() {
        let split = SplitForCycling(number: 1, paceInMinPerKm: 0.0, speedKmH: 30.0)
        XCTAssertEqual(split.formattedPace, "0'00\"/km")
    }

    func test_splitForCycling_codableRoundTrip() throws {
        let original = SplitForCycling(number: 2, paceInMinPerKm: 2.0, speedKmH: 30.0)
        let decoded = try JSONDecoder().decode(
            SplitForCycling.self,
            from: JSONEncoder().encode(original)
        )
        XCTAssertEqual(decoded.number, 2)
        XCTAssertEqual(decoded.speedKmH, 30.0, accuracy: 0.001)
    }

    // MARK: - RunSessionSnapshot Codable

    func test_runSessionSnapshot_codableRoundTrip_fullData() throws {
        let startDate = Date.seconds(10000)
        let splitDate = Date.seconds(10500)
        let splits = [Split(number: 1, paceInMinPerKm: 5.1)]
        let trackPoints = [TrackPoint(timestamp: Date.seconds(10100), latitude: 45.0, longitude: 9.0)]

        let original = RunSessionSnapshot(
            eventId: "event-abc",
            startDate: startDate,
            lastSplitDate: splitDate,
            totalDistanceMeters: 1234.5,
            distanceSinceLastSplit: 200.0,
            elapsedSeconds: 600.0,
            minPace: 4.5,
            maxPace: 6.2,
            splits: splits,
            trackPoints: trackPoints
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RunSessionSnapshot.self, from: data)

        XCTAssertEqual(decoded.eventId, "event-abc")
        XCTAssertEqual(decoded.startDate.timeIntervalSinceReferenceDate,
                       startDate.timeIntervalSinceReferenceDate, accuracy: 0.001)
        XCTAssertEqual(decoded.totalDistanceMeters, 1234.5, accuracy: 0.001)
        XCTAssertEqual(decoded.distanceSinceLastSplit, 200.0, accuracy: 0.001)
        XCTAssertEqual(decoded.elapsedSeconds, 600.0, accuracy: 0.001)
        XCTAssertEqual(decoded.minPace, 4.5, accuracy: 0.001)
        XCTAssertEqual(decoded.maxPace, 6.2, accuracy: 0.001)
        XCTAssertEqual(decoded.splits.count, 1)
        XCTAssertEqual(decoded.trackPoints.count, 1)
        XCTAssertNotNil(decoded.lastSplitDate)
    }

    func test_runSessionSnapshot_codableRoundTrip_nilLastSplitDate() throws {
        // minPace/.infinity can't be encoded by JSONEncoder — use finite sentinel values
        let original = RunSessionSnapshot(
            eventId: "evt",
            startDate: Date(),
            lastSplitDate: nil,
            totalDistanceMeters: 0,
            distanceSinceLastSplit: 0,
            elapsedSeconds: 0,
            minPace: 0,
            maxPace: 0,
            splits: [],
            trackPoints: []
        )
        let decoded = try JSONDecoder().decode(
            RunSessionSnapshot.self,
            from: JSONEncoder().encode(original)
        )
        XCTAssertNil(decoded.lastSplitDate)
        XCTAssertTrue(decoded.splits.isEmpty)
        XCTAssertTrue(decoded.trackPoints.isEmpty)
    }

    // MARK: - HikingSessionSnapshot Codable

    func test_hikingSessionSnapshot_codableRoundTrip() throws {
        let original = HikingSessionSnapshot(
            eventId: "hike-1",
            startDate: Date.seconds(5000),
            lastSplitDate: Date.seconds(5500),
            totalDistanceMeters: 3000,
            distanceSinceLastSplit: 500,
            elevationGainMeters: 200,
            elevationLossMeters: 50,
            maxAltitudeMeters: 1500,
            currentAltitudeMeters: 1200,
            elapsedSeconds: 1800,
            splits: [SplitForHiking(number: 1, paceMinPerKm: 12.0)],
            trackPoints: []
        )

        let decoded = try JSONDecoder().decode(
            HikingSessionSnapshot.self,
            from: JSONEncoder().encode(original)
        )

        XCTAssertEqual(decoded.eventId, "hike-1")
        XCTAssertEqual(decoded.elevationGainMeters, 200, accuracy: 0.001)
        XCTAssertEqual(decoded.elevationLossMeters, 50, accuracy: 0.001)
        XCTAssertEqual(decoded.maxAltitudeMeters, 1500, accuracy: 0.001)
        XCTAssertEqual(decoded.splits.count, 1)
    }

    // MARK: - CyclingSessionSnapshot Codable

    func test_cyclingSessionSnapshot_codableRoundTrip() throws {
        let original = CyclingSessionSnapshot(
            eventId: "cycle-1",
            startDate: Date(),
            lastSplitDate: nil,
            totalDistanceMeters: 5000,
            distanceSinceLastSplit: 100,
            elevationGainMeters: 80,
            elapsedSeconds: 900,
            minSpeedKmH: 20,
            maxSpeedKmH: 45,
            splits: [],
            trackPoints: []
        )

        let decoded = try JSONDecoder().decode(
            CyclingSessionSnapshot.self,
            from: JSONEncoder().encode(original)
        )

        XCTAssertEqual(decoded.minSpeedKmH, 20, accuracy: 0.001)
        XCTAssertEqual(decoded.maxSpeedKmH, 45, accuracy: 0.001)
        XCTAssertEqual(decoded.totalDistanceMeters, 5000, accuracy: 0.001)
    }

    // MARK: - SkiingSessionSnapshot Codable

    func test_skiingSessionSnapshot_codableRoundTrip() throws {
        let original = SkiingSessionSnapshot(
            eventId: "ski-1",
            startDate: Date(),
            lastSplitDate: nil,
            totalDistanceMeters: 8000,
            distanceSinceLastSplit: 0,
            elevationGainMeters: 300,
            verticalDropMeters: 500,
            numberOfRuns: 3,
            isDescending: false,
            elapsedSeconds: 3600,
            maxSpeedKmH: 90,
            splits: [SplitForSkiing(number: 1, speedKmH: 75.0)],
            trackPoints: []
        )

        let decoded = try JSONDecoder().decode(
            SkiingSessionSnapshot.self,
            from: JSONEncoder().encode(original)
        )

        XCTAssertEqual(decoded.verticalDropMeters, 500, accuracy: 0.001)
        XCTAssertEqual(decoded.numberOfRuns, 3)
        XCTAssertFalse(decoded.isDescending)
        XCTAssertEqual(decoded.maxSpeedKmH, 90, accuracy: 0.001)
        XCTAssertEqual(decoded.splits.count, 1)
    }

    // MARK: - CreatorEventUpdate Codable

    func test_creatorEventUpdate_codableRoundTrip() throws {
        let start = Date.seconds(1000)
        let end   = Date.seconds(5000)
        let original = CreatorEventUpdate(
            finalStartDateTime: start,
            finalEndDateTime: end,
            numSession: 4
        )

        let decoded = try JSONDecoder().decode(
            CreatorEventUpdate.self,
            from: JSONEncoder().encode(original)
        )

        XCTAssertEqual(decoded.numSession, 4)
        XCTAssertEqual(decoded.finalStartDateTime.timeIntervalSinceReferenceDate,
                       start.timeIntervalSinceReferenceDate, accuracy: 0.001)
        XCTAssertEqual(decoded.finalEndDateTime.timeIntervalSinceReferenceDate,
                       end.timeIntervalSinceReferenceDate, accuracy: 0.001)
    }

    // MARK: - PendingMetricsUpload init

    func test_pendingMetricsUpload_init_setsAllFields() throws {
        let snapshotData = try JSONEncoder().encode(
            RunSessionSnapshot(
                eventId: "e1", startDate: Date(), lastSplitDate: nil,
                totalDistanceMeters: 0, distanceSinceLastSplit: 0,
                elapsedSeconds: 0, minPace: 0, maxPace: 0,
                splits: [], trackPoints: []
            )
        )

        let before = Date()
        let pending = PendingMetricsUpload(
            eventId: "e1",
            userId: "u1",
            numSession: 2,
            activityType: .running,
            isCreator: true,
            snapshotData: snapshotData,
            creatorEventUpdateData: nil
        )
        let after = Date()

        XCTAssertEqual(pending.eventId, "e1")
        XCTAssertEqual(pending.userId, "u1")
        XCTAssertEqual(pending.numSession, 2)
        XCTAssertEqual(pending.activityType, .running)
        XCTAssertTrue(pending.isCreator)
        XCTAssertNil(pending.creatorEventUpdateData)
        // enqueuedAt should be set in the constructor window
        XCTAssertGreaterThanOrEqual(pending.enqueuedAt, before)
        XCTAssertLessThanOrEqual(pending.enqueuedAt, after)
    }

    func test_pendingMetricsUpload_uniqueIds() throws {
        let data = Data()
        let a = PendingMetricsUpload(eventId: "e", userId: "u", numSession: 1,
                                     activityType: .gym, isCreator: false,
                                     snapshotData: data)
        let b = PendingMetricsUpload(eventId: "e", userId: "u", numSession: 1,
                                     activityType: .gym, isCreator: false,
                                     snapshotData: data)
        XCTAssertNotEqual(a.id, b.id)
    }

    // MARK: - MetricsCollectorPersistable.checkpointKey

    func test_checkpointKey_includesTypeNameAndEventId() {
        let sut = MetricsCollectorRun(
            isCreator: true,
            numSessions: 1,
            locationManager: MockSessionLocationManager(),
            healthKit: MockHealthKitService(),
            userIdProvider: { "u1" }
        )
        let key = sut.checkpointKey(eventId: "event-123")
        XCTAssertTrue(key.contains("MetricsCollectorRun"))
        XCTAssertTrue(key.contains("event-123"))
    }

    func test_checkpointKey_differentTypesProduceDifferentKeys() {
        let mockLoc = MockSessionLocationManager()
        let mockHK  = MockHealthKitService()

        let run  = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                        locationManager: mockLoc, healthKit: mockHK,
                                        userIdProvider: { "u" })
        let hike = MetricsCollectorHiking(isCreator: true, numSessions: 1,
                                           locationManager: mockLoc, healthKit: mockHK,
                                           userIdProvider: { "u" })

        XCTAssertNotEqual(
            run.checkpointKey(eventId: "e"),
            hike.checkpointKey(eventId: "e")
        )
    }
}
