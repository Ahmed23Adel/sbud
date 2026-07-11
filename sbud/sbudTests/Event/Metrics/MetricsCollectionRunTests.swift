//
//  MockSessionLocationManager.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 11/07/2026.
//


import XCTest
import CoreLocation
import Combine
import FirebaseFirestore
import HealthKit
@testable import sbud

// MARK: - Mocks

final class MockSessionLocationManager: SessionLocationManaging {
    let subject = CurrentValueSubject<CLLocation?, Never>(nil)
    var lastLocationPublisher: AnyPublisher<CLLocation?, Never> { subject.eraseToAnyPublisher() }

    private(set) var startUpdatingCalled = false
    private(set) var stopUpdatingCalled = false
    private let realManager = CLLocationManager() // per applyConfiguration

    func startUpdating() { startUpdatingCalled = true }
    func stopUpdating() { stopUpdatingCalled = true }
    func applyConfiguration(_ configure: (CLLocationManager) -> Void) { configure(realManager) }
}

final class MockHealthKitService: HealthKitServing {
    private(set) var authorizationRequested = false
    private(set) var savedWorkouts: [(activity: HKWorkoutActivityType, distance: Double)] = []

    func requestAuthorization() async { authorizationRequested = true }
    func saveGPSWorkout(activityType: HKWorkoutActivityType, start: Date, end: Date,
                        distanceMeters: Double, locations: [CLLocation]) async throws {
        savedWorkouts.append((activityType, distanceMeters))
        
    }
    private(set) var savedTimeBasedWorkouts: [(activity: HKWorkoutActivityType, start: Date, end: Date)] = []

        func saveTimeBasedWorkout(activityType: HKWorkoutActivityType, start: Date, end: Date) async throws {
            savedTimeBasedWorkouts.append((activityType, start, end))
        }
}

// MARK: - Helpers

func makeLocation(lat: Double, lon: Double,
                  altitude: Double = 100,
                  accuracy: Double = 10,
                  speed: Double = 3.0,
                  timestamp: Date) -> CLLocation {
    CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
               altitude: altitude, horizontalAccuracy: accuracy, verticalAccuracy: 10,
               course: 0, speed: speed, timestamp: timestamp)
}

// MARK: - MetricsCollectorUtils (logica pura)

final class MetricsCollectorUtilsTests: XCTestCase {

    let t0 = Date(timeIntervalSince1970: 1_000_000)

    // isValidLocation

    func test_isValid_goodLocation_noPrevious() {
        let loc = makeLocation(lat: 45, lon: 9, timestamp: t0)
        XCTAssertTrue(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_isValid_badAccuracy_rejected() {
        let loc = makeLocation(lat: 45, lon: 9, accuracy: 50, timestamp: t0)
        XCTAssertFalse(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_isValid_negativeAccuracy_rejected() {
        let loc = makeLocation(lat: 45, lon: 9, accuracy: -1, timestamp: t0)
        XCTAssertFalse(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_isValid_negativeSpeed_rejected() {
        let loc = makeLocation(lat: 45, lon: 9, speed: -1, timestamp: t0)
        XCTAssertFalse(MetricsCollectorUtils.isValidLocation(loc, lastLocation: nil))
    }

    func test_isValid_tooCloseInTime_rejected() {
        let a = makeLocation(lat: 45, lon: 9, timestamp: t0)
        let b = makeLocation(lat: 45.0001, lon: 9, timestamp: t0.addingTimeInterval(0.5))
        XCTAssertFalse(MetricsCollectorUtils.isValidLocation(b, lastLocation: a))
    }

    func test_isValid_enoughTimePassed_accepted() {
        let a = makeLocation(lat: 45, lon: 9, timestamp: t0)
        let b = makeLocation(lat: 45.0001, lon: 9, timestamp: t0.addingTimeInterval(2))
        XCTAssertTrue(MetricsCollectorUtils.isValidLocation(b, lastLocation: a))
    }

    // computeDistance

    func test_computeDistance_emptyOrSingle_isZero() {
        XCTAssertEqual(MetricsCollectorUtils.computeDistance(from: []), 0)
        XCTAssertEqual(MetricsCollectorUtils.computeDistance(from: [makeLocation(lat: 45, lon: 9, timestamp: t0)]), 0)
    }

    func test_computeDistance_sumsSegments() {
        // ~111 metri per 0.001° di latitudine
        let a = makeLocation(lat: 45.000, lon: 9, timestamp: t0)
        let b = makeLocation(lat: 45.001, lon: 9, timestamp: t0.addingTimeInterval(10))
        let c = makeLocation(lat: 45.002, lon: 9, timestamp: t0.addingTimeInterval(20))

        let dist = MetricsCollectorUtils.computeDistance(from: [a, b, c])

        XCTAssertEqual(dist, 222, accuracy: 5)
    }

    // Elevation

    func test_elevationGain_countsOnlyClimbs() {
        let locs = [100.0, 110, 105, 120].enumerated().map { i, alt in
            makeLocation(lat: 45, lon: 9, altitude: alt, timestamp: t0.addingTimeInterval(Double(i * 10)))
        }
        XCTAssertEqual(MetricsCollectorUtils.computeElevationGain(from: locs), 25) // +10 +15
    }

    func test_elevationLoss_countsOnlyDescents() {
        let locs = [100.0, 90, 95, 80].enumerated().map { i, alt in
            makeLocation(lat: 45, lon: 9, altitude: alt, timestamp: t0.addingTimeInterval(Double(i * 10)))
        }
        XCTAssertEqual(MetricsCollectorUtils.computeElevationLoss(from: locs), 25) // -10 -15
    }

    func test_verticalDrop_matchesLossSemantics() {
        let locs = [200.0, 150, 170, 100].enumerated().map { i, alt in
            makeLocation(lat: 45, lon: 9, altitude: alt, timestamp: t0.addingTimeInterval(Double(i * 10)))
        }
        XCTAssertEqual(MetricsCollectorUtils.computeVerticalDrop(from: locs), 120) // 50 + 70
    }

    func test_numberOfRuns_countsDescendingStretches() {
        // discesa, risalita, discesa → 2 run
        let locs = [300.0, 250, 200, 260, 210].enumerated().map { i, alt in
            makeLocation(lat: 45, lon: 9, altitude: alt, timestamp: t0.addingTimeInterval(Double(i * 10)))
        }
        XCTAssertEqual(MetricsCollectorUtils.computeNumberOfRuns(from: locs), 2)
    }

    func test_numberOfRuns_flatTrack_zero() {
        let locs = [100.0, 100, 100].enumerated().map { i, alt in
            makeLocation(lat: 45, lon: 9, altitude: alt, timestamp: t0.addingTimeInterval(Double(i * 10)))
        }
        XCTAssertEqual(MetricsCollectorUtils.computeNumberOfRuns(from: locs), 0)
    }

    // Trim / elapsed / conversione

    func test_trimTrack_keepsOnlyBeforeCutoff() {
        let track: [(Date, CLLocation)] = (0..<5).map { i in
            let d = t0.addingTimeInterval(Double(i * 60))
            return (d, makeLocation(lat: 45, lon: 9, timestamp: d))
        }
        let cutoff = t0.addingTimeInterval(150) // tiene i primi 3

        XCTAssertEqual(MetricsCollectorUtils.trimTrack(track, to: cutoff).count, 3)
    }

    func test_trimmedElapsed_lastMinusFirst() {
        let track: [(Date, CLLocation)] = [
            (t0, makeLocation(lat: 45, lon: 9, timestamp: t0)),
            (t0.addingTimeInterval(300), makeLocation(lat: 45, lon: 9, timestamp: t0.addingTimeInterval(300)))
        ]
        XCTAssertEqual(MetricsCollectorUtils.trimmedElapsed(from: track, fallback: 99), 300)
    }

    func test_trimmedElapsed_emptyTrack_usesFallback() {
        XCTAssertEqual(MetricsCollectorUtils.trimmedElapsed(from: [], fallback: 42), 42)
    }

    func test_toTrackPoints_mapsCoordinatesAndTimestamps() {
        let track: [(Date, CLLocation)] = [(t0, makeLocation(lat: 45.5, lon: 9.2, timestamp: t0))]
        let points = track.toTrackPoints()
        XCTAssertEqual(points.count, 1)
        XCTAssertEqual(points[0].latitude, 45.5)
        XCTAssertEqual(points[0].longitude, 9.2)
        XCTAssertEqual(points[0].timestamp, t0)
    }

    // readFinalEndDateTime (emulatore)

    func test_readFinalEndDateTime_present_returnsDate() async throws {
        let end = Date(timeIntervalSince1970: 2_000_000)
        try await Firestore.firestore().collection("Events").document("metrics_evt")
            .setData(["finalEndDateTime": Timestamp(date: end)])

        let result = try await MetricsCollectorUtils.readFinalEndDateTime(eventId: "metrics_evt")

        XCTAssertEqual(result?.timeIntervalSince1970 ?? 0, end.timeIntervalSince1970, accuracy: 1)
    }

    func test_readFinalEndDateTime_absent_returnsNil() async throws {
        try await Firestore.firestore().collection("Events").document("metrics_evt_2")
            .setData(["title": "in corso"])

        let result = try await MetricsCollectorUtils.readFinalEndDateTime(eventId: "metrics_evt_2")

        XCTAssertNil(result)
    }
}

// MARK: - MetricsCollectorRun

@MainActor
final class MetricsCollectorRunTests: XCTestCase {

    private var location: MockSessionLocationManager!
    private var healthKit: MockHealthKitService!
    private var sut: MetricsCollectorRun!
    private let eventId = "run_evt_test"
    private let t0 = Date()

    override func setUp() {
        super.setUp()
        location = MockSessionLocationManager()
        healthKit = MockHealthKitService()
        sut = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                  locationManager: location, healthKit: healthKit,
                                  userIdProvider: { "run_user" })
        sut.clearCheckpoint(eventId: eventId) // niente residui tra i run
    }

    override func tearDown() {
        sut.clearCheckpoint(eventId: eventId)
        sut = nil; healthKit = nil; location = nil
        super.tearDown()
    }

    private func push(_ loc: CLLocation) { location.subject.send(loc) }

    // start

    func test_startSession_fresh_setsTrackingAndStartsUpdates() {
        sut.startSession(eventId: eventId)
        XCTAssertTrue(sut.isTracking)
        XCTAssertTrue(location.startUpdatingCalled)
        XCTAssertTrue(sut.trackedLocations.isEmpty)
    }

    // accumulo distanza

    func test_locations_accumulateDistance() {
        sut.startSession(eventId: eventId)

        push(makeLocation(lat: 45.000, lon: 9, timestamp: t0))
        push(makeLocation(lat: 45.001, lon: 9, timestamp: t0.addingTimeInterval(10)))
        push(makeLocation(lat: 45.002, lon: 9, timestamp: t0.addingTimeInterval(20)))

        XCTAssertEqual(sut.trackedLocations.count, 3)
        XCTAssertEqual(sut.totalDistanceMeters, 222, accuracy: 5)
    }

    func test_locations_ignoredWhenNotTracking() {
        push(makeLocation(lat: 45, lon: 9, timestamp: t0))
        XCTAssertTrue(sut.trackedLocations.isEmpty)
    }

    func test_invalidAccuracy_filtered() {
        sut.startSession(eventId: eventId)

        push(makeLocation(lat: 45, lon: 9, timestamp: t0))
        push(makeLocation(lat: 45.001, lon: 9, accuracy: 80, timestamp: t0.addingTimeInterval(10)))

        XCTAssertEqual(sut.trackedLocations.count, 1)
        XCTAssertEqual(sut.totalDistanceMeters, 0)
    }

    func test_tooFrequentUpdates_filtered() {
        sut.startSession(eventId: eventId)

        push(makeLocation(lat: 45, lon: 9, timestamp: t0))
        push(makeLocation(lat: 45.001, lon: 9, timestamp: t0.addingTimeInterval(0.3)))

        XCTAssertEqual(sut.trackedLocations.count, 1)
    }

    // pace

    func test_currentPace_updatesFromSpeed() {
        sut.startSession(eventId: eventId)

        push(makeLocation(lat: 45, lon: 9, speed: 3.0, timestamp: t0))
        push(makeLocation(lat: 45.001, lon: 9, speed: 3.333, timestamp: t0.addingTimeInterval(10)))

        // 1000/3.333/60 ≈ 5 min/km
        XCTAssertEqual(sut.currentPaceMinPerKm, 5.0, accuracy: 0.1)
    }

    func test_currentPace_notUpdated_whenTooSlow() {
        sut.startSession(eventId: eventId)

        push(makeLocation(lat: 45, lon: 9, speed: 3.0, timestamp: t0))
        push(makeLocation(lat: 45.001, lon: 9, speed: 0.2, timestamp: t0.addingTimeInterval(10)))

        XCTAssertEqual(sut.currentPaceMinPerKm, 0, "Sotto 0.5 m/s il pace non si aggiorna")
    }

    // split

    func test_split_createdAfter1000Meters() {
        sut.startSession(eventId: eventId)

        // 11 punti da ~111m = ~1110m percorsi
        for i in 0...10 {
            push(makeLocation(lat: 45.0 + Double(i) * 0.001, lon: 9,
                              timestamp: t0.addingTimeInterval(Double(i) * 60)))
        }

        XCTAssertEqual(sut.splits.count, 1)
        XCTAssertEqual(sut.splits.first?.number, 1)
        XCTAssertGreaterThan(sut.splits.first?.paceInMinPerKm ?? 0, 0)
    }

    func test_noSplit_underThreshold() {
        sut.startSession(eventId: eventId)

        for i in 0...3 { // ~333m
            push(makeLocation(lat: 45.0 + Double(i) * 0.001, lon: 9,
                              timestamp: t0.addingTimeInterval(Double(i) * 60)))
        }

        XCTAssertTrue(sut.splits.isEmpty)
    }

    // checkpoint

    func test_checkpoint_saveAndRestore_roundTrip() {
        sut.startSession(eventId: eventId)
        push(makeLocation(lat: 45, lon: 9, timestamp: t0))
        push(makeLocation(lat: 45.001, lon: 9, timestamp: t0.addingTimeInterval(10)))
        let distance = sut.totalDistanceMeters
        sut.saveCheckpoint(eventId: eventId)

        // Nuovo collector: al restore deve ritrovare tutto
        let restored = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                           locationManager: MockSessionLocationManager(),
                                           healthKit: MockHealthKitService(),
                                           userIdProvider: { "run_user" })
        XCTAssertTrue(restored.restoreCheckpoint(eventId: eventId))
        XCTAssertEqual(restored.totalDistanceMeters, distance, accuracy: 0.01)
        XCTAssertEqual(restored.trackedLocations.count, 2)
    }

    func test_restoreCheckpoint_noData_returnsFalse() {
        XCTAssertFalse(sut.restoreCheckpoint(eventId: "mai_esistito"))
    }

    func test_startSession_withExistingCheckpoint_restoresInsteadOfReset() {
        sut.startSession(eventId: eventId)
        push(makeLocation(lat: 45, lon: 9, timestamp: t0))
        push(makeLocation(lat: 45.001, lon: 9, timestamp: t0.addingTimeInterval(10)))
        sut.saveCheckpoint(eventId: eventId)
        let savedDistance = sut.totalDistanceMeters

        let second = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                         locationManager: MockSessionLocationManager(),
                                         healthKit: MockHealthKitService(),
                                         userIdProvider: { "run_user" })
        second.startSession(eventId: eventId)

        XCTAssertEqual(second.totalDistanceMeters, savedDistance, accuracy: 0.01,
                       "Con checkpoint presente non deve azzerare")
        second.clearCheckpoint(eventId: eventId)
    }

    // endSession (solo il ramo pre-upload testabile)

    func test_endSession_withoutUser_throwsProfileNotAvailable_andStopsTracking() async {
        let noUser = MetricsCollectorRun(isCreator: true, numSessions: 1,
                                         locationManager: location, healthKit: healthKit,
                                         userIdProvider: { nil })
        noUser.startSession(eventId: eventId)

        do {
            try await noUser.endSession(event: .fixture(id: eventId))
            XCTFail("Doveva lanciare profileNotAvailable")
        } catch let error as MetricsError {
            XCTAssertEqual(error, .profileNotAvailable)
        } catch {
            XCTFail("Errore inatteso: \(error)")
        }
        XCTAssertFalse(noUser.isTracking)
        XCTAssertTrue(location.stopUpdatingCalled)
        noUser.clearCheckpoint(eventId: eventId)
    }
}
