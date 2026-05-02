//
//  AvailabilityModuleTests.swift
//  sbudTests
//
//  Created by ahmed on 28/04/2026.
//
// Tests for the Availability module: ViewModel, MapsHelper, LocationManager, Filters, DataFetcher

import XCTest
import MapKit
import Combine
import CoreLocation
import FirebaseFirestore
@testable import sbud
internal import SwiftUI

// MARK: - Mocks

// MARK: MockAvailabilityDataFetcher
final class MockAvailabilityDataFetcher: AvailabilityDataFetcher {
    var shouldThrow = false
    var stubbedClusters: [AnchorCluster] = []
    var stubbedIndividuals: [AnchorAvailabilityEvent] = []

    var fetchClustersCallCount = 0
    var fetchIndividualsCallCount = 0

    override func fetchClusters(
        selectedStartTime: Date,
        selectedEndTime: Date,
        topLeft: GeoPoint,
        bottomRight: GeoPoint,
        selectedActivityType: ActivityType
    ) async throws -> [AnchorCluster] {
        fetchClustersCallCount += 1
        if shouldThrow { throw NSError(domain: "MockError", code: 1) }
        return stubbedClusters
    }

    override func fetchIndividuals(
        in region: MKCoordinateRegion,
        selectedStartDateTime: Date,
        selectedEndDateTime: Date,
        selectedActivityType: ActivityType
    ) async throws -> [AnchorAvailabilityEvent] {
        fetchIndividualsCallCount += 1
        if shouldThrow { throw NSError(domain: "MockError", code: 2) }
        return stubbedIndividuals
    }
}

// MARK: MockAvailabilityAggregate
final class MockAvailabilityAggregate: IAailabilityAggregate {
    var id: String
    var count: Int
    var location: GeoPoint

    init(
        id: String = "test-id",
        count: Int = 5,
        location: GeoPoint = GeoPoint(latitude: 45.0, longitude: 9.0)
    ) {
        self.id = id
        self.count = count
        self.location = location
    }

    static func == (lhs: MockAvailabilityAggregate, rhs: MockAvailabilityAggregate) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: MockAvailabilityEvent
final class MockAvailabilityEvent: IAvailabilityEvent {
    var id: String
    var geoPoint: GeoPoint
    var eventImage: String

    init(
        id: String = "event-1",
        geoPoint: GeoPoint = GeoPoint(latitude: 45.0, longitude: 9.0),
        eventImage: String = "image.png"
    ) {
        self.id = id
        self.geoPoint = geoPoint
        self.eventImage = eventImage
    }

    static func == (lhs: MockAvailabilityEvent, rhs: MockAvailabilityEvent) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - MapsHelper Tests

final class MapsHelperTests: XCTestCase {

    var sut: MapsHelper!

    override func setUp() {
        super.setUp()
        sut = MapsHelper()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: determinePrecision

    func test_determinePrecision_veryZoomedIn_returnsIndividuals() {
        XCTAssertEqual(sut.determinePrecision(from: makeRegion(latDelta: 0.005)), .individuals)
    }

    func test_determinePrecision_slightlyZoomedIn_returnsIndividuals() {
        XCTAssertEqual(sut.determinePrecision(from: makeRegion(latDelta: 0.03)), .individuals)
    }

    func test_determinePrecision_cityLevel_returnsCity() {
        XCTAssertEqual(sut.determinePrecision(from: makeRegion(latDelta: 0.1)), .city)
    }

    func test_determinePrecision_largeCityLevel_returnsLargeCity() {
        XCTAssertEqual(sut.determinePrecision(from: makeRegion(latDelta: 0.5)), .largeCity)
    }

    func test_determinePrecision_countryLevel_returnsCountry() {
        XCTAssertEqual(sut.determinePrecision(from: makeRegion(latDelta: 2.0)), .country)
    }

    func test_determinePrecision_veryZoomedOut_returnsContinent() {
        XCTAssertEqual(sut.determinePrecision(from: makeRegion(latDelta: 30.0)), .continent)
    }

    // MARK: isNewRegionContained

    func test_isNewRegionContained_fullyContained_returnsTrue() {
        let old = makeRegion(latDelta: 0.5)
        let new = makeRegion(latDelta: 0.1)
        XCTAssertTrue(sut.isNewRegionContained(new: new, old: old))
    }

    func test_isNewRegionContained_newLargerThanOld_returnsFalse() {
        let old = makeRegion(latDelta: 0.1)
        let new = makeRegion(
            center: CLLocationCoordinate2D(latitude: 46, longitude: 10),
            latDelta: 0.5
        )
        XCTAssertFalse(sut.isNewRegionContained(new: new, old: old))
    }

    func test_isNewRegionContained_partialOverlap_returnsFalse() {
        let old = makeRegion(latDelta: 0.2)
        let new = makeRegion(
            center: CLLocationCoordinate2D(latitude: 45.15, longitude: 9.15),
            latDelta: 0.2
        )
        XCTAssertFalse(sut.isNewRegionContained(new: new, old: old))
    }

    func test_isNewRegionContained_sameRegion_returnsTrue() {
        let region = makeRegion(latDelta: 0.2)
        XCTAssertTrue(sut.isNewRegionContained(new: region, old: region))
    }

    // MARK: calcCenterForLoc

    func test_calcCenterForLoc_returnsCorrectMidpoint() {
        let center = sut.calcCenterForLoc(minLat: 44.0, maxLat: 46.0, minLon: 8.0, maxLon: 10.0)
        XCTAssertEqual(center.latitude, 45.0, accuracy: 0.0001)
        XCTAssertEqual(center.longitude, 9.0, accuracy: 0.0001)
    }

    func test_calcCenterForLoc_sameMinMax_returnsSamePoint() {
        let center = sut.calcCenterForLoc(minLat: 45.0, maxLat: 45.0, minLon: 9.0, maxLon: 9.0)
        XCTAssertEqual(center.latitude, 45.0, accuracy: 0.0001)
        XCTAssertEqual(center.longitude, 9.0, accuracy: 0.0001)
    }

    // MARK: calcDelta

    func test_calcDelta_tinyDifference_returnsCityZoomMinimum() {
        let (latDelta, lonDelta) = sut.calcDelta(maxLat: 45.001, minLat: 45.0, maxLon: 9.001, minLon: 9.0)
        XCTAssertEqual(latDelta, sut.cityZoomLatitudeDelta, accuracy: 0.001)
        XCTAssertEqual(lonDelta, sut.cityZoomLongitudeDelta, accuracy: 0.001)
    }

    func test_calcDelta_largeDifference_returnsScaledValues() {
        let (latDelta, lonDelta) = sut.calcDelta(maxLat: 46.0, minLat: 44.0, maxLon: 10.0, minLon: 8.0)
        XCTAssertEqual(latDelta, 2.6, accuracy: 0.001) // 2.0 * 1.3
        XCTAssertEqual(lonDelta, 2.6, accuracy: 0.001)
    }

    // MARK: Default zoom values

    func test_cityZoomDefaults_areWithinReasonableBounds() {
        XCTAssertGreaterThan(sut.cityZoomLatitudeDelta, 0)
        XCTAssertGreaterThan(sut.cityZoomLongitudeDelta, 0)
        XCTAssertLessThan(sut.cityZoomLatitudeDelta, 1.0)
        XCTAssertLessThan(sut.cityZoomLongitudeDelta, 1.0)
    }

    // MARK: - Helper

    private func makeRegion(
        center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 45, longitude: 9),
        latDelta: Double
    ) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: latDelta)
        )
    }
}

// MARK: - GeohashPrecision Tests

final class GeohashPrecisionTests: XCTestCase {

    func test_rawValues_matchExpectedIntegers() {
        XCTAssertEqual(GeohashPrecision.continent.rawValue, 1)
        XCTAssertEqual(GeohashPrecision.country.rawValue, 2)
        XCTAssertEqual(GeohashPrecision.largeCity.rawValue, 3)
        XCTAssertEqual(GeohashPrecision.city.rawValue, 4)
        XCTAssertEqual(GeohashPrecision.neighbourhood.rawValue, 5)
        XCTAssertEqual(GeohashPrecision.district.rawValue, 6)
        XCTAssertEqual(GeohashPrecision.individuals.rawValue, 8)
    }

    func test_initFromRawValue_validValues_returnCorrectCases() {
        XCTAssertEqual(GeohashPrecision(rawValue: 5), .neighbourhood)
        XCTAssertEqual(GeohashPrecision(rawValue: 8), .individuals)
        XCTAssertEqual(GeohashPrecision(rawValue: 1), .continent)
    }

    func test_initFromRawValue_invalidValues_returnNil() {
        XCTAssertNil(GeohashPrecision(rawValue: 99))
        XCTAssertNil(GeohashPrecision(rawValue: 0))
        XCTAssertNil(GeohashPrecision(rawValue: -1))
    }
}

// MARK: - AnchorCluster Tests

final class AnchorClusterTests: XCTestCase {

    func test_init_setsClusterAndCount() {
        let aggregate = MockAvailabilityAggregate(id: "abc", count: 7)
        let cluster = AnchorCluster(cluster: aggregate)
        XCTAssertEqual(cluster.count, 7)
        XCTAssertEqual(cluster.cluster.id, "abc")
    }

    func test_equality_sameId_returnsTrue() {
        let c1 = AnchorCluster(cluster: MockAvailabilityAggregate(id: "same"))
        let c2 = AnchorCluster(cluster: MockAvailabilityAggregate(id: "same"))
        XCTAssertEqual(c1, c2)
    }

    func test_equality_differentId_returnsFalse() {
        let c1 = AnchorCluster(cluster: MockAvailabilityAggregate(id: "id-1"))
        let c2 = AnchorCluster(cluster: MockAvailabilityAggregate(id: "id-2"))
        XCTAssertNotEqual(c1, c2)
    }

    func test_count_delegatesToAggregate() {
        let cluster = AnchorCluster(cluster: MockAvailabilityAggregate(count: 42))
        XCTAssertEqual(cluster.count, 42)
    }

    func test_count_zeroIsValid() {
        let cluster = AnchorCluster(cluster: MockAvailabilityAggregate(count: 0))
        XCTAssertEqual(cluster.count, 0)
    }
}

// MARK: - AnchorAvailabilityEvent Tests

final class AnchorAvailabilityEventTests: XCTestCase {

    func test_init_setsIdFromEvent() {
        let anchor = AnchorAvailabilityEvent(
            eventId: "evt-1",
            event: MockAvailabilityEvent(id: "evt-1")
        )
        XCTAssertEqual(anchor.id, "evt-1")
        XCTAssertEqual(anchor.eventId, "evt-1")
    }

    func test_equality_sameEventId_returnsTrue() {
        let a1 = AnchorAvailabilityEvent(eventId: "x", event: MockAvailabilityEvent(id: "x"))
        let a2 = AnchorAvailabilityEvent(eventId: "x", event: MockAvailabilityEvent(id: "x"))
        XCTAssertEqual(a1, a2)
    }

    func test_equality_differentEventId_returnsFalse() {
        let a1 = AnchorAvailabilityEvent(eventId: "A", event: MockAvailabilityEvent(id: "A"))
        let a2 = AnchorAvailabilityEvent(eventId: "B", event: MockAvailabilityEvent(id: "B"))
        XCTAssertNotEqual(a1, a2)
    }

    func test_description_containsId() {
        let anchor = AnchorAvailabilityEvent(
            eventId: "desc-test",
            event: MockAvailabilityEvent(id: "desc-test")
        )
        XCTAssertTrue(anchor.description.contains("desc-test"))
    }
}

// MARK: - AvailabilityFiltersResults Tests

final class AvailabilityFiltersResultsTests: XCTestCase {

    var sut: AvailabilityFiltersResults!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        sut = AvailabilityFiltersResults()
    }

    override func tearDown() {
        sut = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: Defaults

    func test_defaultSelectedActivityIndex_isZero() {
        XCTAssertEqual(sut.selectedActivityIndex, 0)
    }

    func test_defaultStartDateTime_isApproximatelyNow() {
        XCTAssertEqual(sut.startDateTime.timeIntervalSinceNow, 0, accuracy: 2.0)
    }

    func test_defaultEndDateTime_isFiveHoursAfterStart() {
        let diff = sut.endDateTime.timeIntervalSince(sut.startDateTime)
        XCTAssertEqual(diff, 5 * 3600, accuracy: 2.0)
    }

    // MARK: selectedActivity

    func test_selectedActivity_index0_returnsRunning() {
        sut.selectedActivityIndex = 0
        XCTAssertEqual(sut.selectedActivity, .running)
    }

    func test_selectedActivity_index1_returnsCycling() {
        sut.selectedActivityIndex = 1
        XCTAssertEqual(sut.selectedActivity, .cycling)
    }

    func test_selectedActivity_index2_returnsGym() {
        sut.selectedActivityIndex = 2
        XCTAssertEqual(sut.selectedActivity, .gym)
    }

    func test_selectedActivity_outOfBoundsIndex_returnsGym() {
        sut.selectedActivityIndex = 99
        XCTAssertEqual(sut.selectedActivity, .gym)
    }

    // MARK: Publishing

    func test_selectedActivityIndex_publishesNewValue() {
        let expectation = expectation(description: "selectedActivityIndex published")

        sut.$selectedActivityIndex
            .dropFirst()
            .sink { newValue in
                XCTAssertEqual(newValue, 2)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.selectedActivityIndex = 2
        waitForExpectations(timeout: 1.0)
    }

    func test_startDateTime_publishesNewValue() {
        let expectation = expectation(description: "startDateTime published")
        let newDate = Date().addingTimeInterval(3600)

        sut.$startDateTime
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.startDateTime = newDate
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(sut.startDateTime, newDate)
    }

    func test_endDateTime_publishesNewValue() {
        let expectation = expectation(description: "endDateTime published")
        let newDate = Date().addingTimeInterval(7200)

        sut.$endDateTime
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.endDateTime = newDate
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(sut.endDateTime, newDate)
    }
}

// MARK: - AvailbilityViewModel Tests
// LocationManager uses `private override init()` (singleton), so it cannot be subclassed.
// We use LocationManager.shared directly and set `userLocation` before each test.

@MainActor
final class AvailbilityViewModelTests: XCTestCase {

    var sut: AvailbilityViewModel!
    var filters: AvailabilityFiltersResults!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        LocationManager.shared.userLocation = CLLocationCoordinate2D(latitude: 45.46, longitude: 9.19)
        filters = AvailabilityFiltersResults()
        sut = AvailbilityViewModel(
            locationManager: LocationManager.shared,
            availabilityFiltersResults: filters
        )
    }

    override func tearDown() {
        sut = nil
        filters = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: Initialisation

    func test_init_selectedTabIsZero() {
        XCTAssertEqual(sut.selectedTab, 0)
    }

    func test_init_shouldShowIndividualsIsFalse() {
        XCTAssertFalse(sut.shouldShowIndividuals)
    }

    func test_init_showErrorAlertIsFalse() {
        XCTAssertFalse(sut.showErrorAlert)
    }

    func test_init_alertMsgIsEmpty() {
        XCTAssertEqual(sut.alertMsg, "")
    }

    func test_init_currentCameraPrecisionIsNeighbourhood() {
        XCTAssertEqual(sut.currentCameraPrecision, .neighbourhood)
    }

    func test_init_anchorsClustersIsAnArray() {
        XCTAssertNotNil(sut.anchorsClusters)
    }

    func test_init_anchorAvailabilityEventsIsAnArray() {
        XCTAssertNotNil(sut.anchorAvailabilityEvents)
    }

    // MARK: zoomToCity

    func test_zoomToCity_withExplicitCenter_updatesCameraPosition() {
        sut.zoomToCity(center: CLLocationCoordinate2D(latitude: 48.85, longitude: 2.35))
        if case .automatic = sut.cameraPosition {
            XCTFail("cameraPosition should not be .automatic after zoomToCity")
        }
    }

    func test_zoomToCity_withoutCenter_usesUserLocation() {
        LocationManager.shared.userLocation = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12)
        sut.zoomToCity()
        if case .automatic = sut.cameraPosition {
            XCTFail("cameraPosition should be set using user location")
        }
    }

    func test_zoomToCity_noUserLocation_fallsBackToZeroZero() {
        LocationManager.shared.userLocation = nil
        sut.zoomToCity()
        if case .automatic = sut.cameraPosition {
            XCTFail("cameraPosition should fall back to 0,0 region without crashing")
        }
    }

    // MARK: updateListId

    func test_updateListId_generatesNewId() {
        let oldId = sut.listViewRefreshId
        sut.updateListId()
        XCTAssertNotEqual(sut.listViewRefreshId, oldId)
    }

    func test_updateListId_calledTwice_generatesTwoDistinctIds() {
        sut.updateListId()
        let firstId = sut.listViewRefreshId
        sut.updateListId()
        XCTAssertNotEqual(sut.listViewRefreshId, firstId)
    }

    // MARK: handleMapCameraChange

    func test_handleMapCameraChange_whenCurrentRegionIsNil_setsRegion() {
        sut.currentRegion = nil
        sut.handleMapCameraChange(makeRegion(latDelta: 0.1))
        XCTAssertNotNil(sut.currentRegion)
    }

    func test_handleMapCameraChange_individualsZoom_setsShouldShowIndividuals() {
        sut.handleMapCameraChange(makeRegion(latDelta: 0.005))
        XCTAssertTrue(sut.shouldShowIndividuals)
        XCTAssertEqual(sut.currentCameraPrecision, .individuals)
    }

    func test_handleMapCameraChange_cityZoom_clearsShouldShowIndividuals() {
        sut.handleMapCameraChange(makeRegion(latDelta: 0.1))
        XCTAssertFalse(sut.shouldShowIndividuals)
        XCTAssertEqual(sut.currentCameraPrecision, .city)
    }

    func test_handleMapCameraChange_largeCityZoom_setsCorrectPrecision() {
        sut.handleMapCameraChange(makeRegion(latDelta: 0.5))
        XCTAssertEqual(sut.currentCameraPrecision, .largeCity)
    }

    func test_handleMapCameraChange_containedRegion_updatesCurrentRegion() {
        sut.handleMapCameraChange(makeRegion(latDelta: 0.5))
        sut.handleMapCameraChange(makeRegion(latDelta: 0.2))
        XCTAssertNotNil(sut.currentRegion)
    }

    func test_handleMapCameraChange_repeatedIndividualsZoom_keepsShouldShowIndividualsTrue() {
        sut.handleMapCameraChange(makeRegion(latDelta: 0.005))
        sut.handleMapCameraChange(makeRegion(latDelta: 0.004))
        XCTAssertTrue(sut.shouldShowIndividuals)
    }

    // MARK: changeSelectedActivity

    func test_changeSelectedActivity_doesNotTriggerErrorAlert() {
        sut.changeSelectedActivity(selectedActivityIndex: 1)
        XCTAssertFalse(sut.showErrorAlert)
    }

    func test_changeSelectedActivity_multipleCallsDoNotCrash() {
        for i in 0..<3 {
            sut.changeSelectedActivity(selectedActivityIndex: i)
        }
        XCTAssertFalse(sut.showErrorAlert)
    }


    // MARK: - Helper

    private func makeRegion(latDelta: Double) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45, longitude: 9),
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: latDelta)
        )
    }
}

// MARK: - AvailabilityDataFetcher Tests

final class AvailabilityDataFetcherTests: XCTestCase {

    var sut: MockAvailabilityDataFetcher!

    override func setUp() {
        super.setUp()
        sut = MockAvailabilityDataFetcher()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: fetchClusters

    func test_fetchClusters_success_returnsExpectedData() async throws {
        sut.stubbedClusters = [AnchorCluster(cluster: MockAvailabilityAggregate(id: "c1", count: 3))]

        let results = try await sut.fetchClusters(
            selectedStartTime: Date(),
            selectedEndTime: Date().addingTimeInterval(3600),
            topLeft: GeoPoint(latitude: 46, longitude: 8),
            bottomRight: GeoPoint(latitude: 44, longitude: 10),
            selectedActivityType: .running
        )

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.count, 3)
    }

    func test_fetchClusters_incrementsCallCount() async throws {
        _ = try await sut.fetchClusters(
            selectedStartTime: Date(), selectedEndTime: Date(),
            topLeft: GeoPoint(latitude: 0, longitude: 0),
            bottomRight: GeoPoint(latitude: 0, longitude: 0),
            selectedActivityType: .running
        )
        XCTAssertEqual(sut.fetchClustersCallCount, 1)
    }

    func test_fetchClusters_calledTwice_callCountIsTwo() async throws {
        for _ in 0..<2 {
            _ = try await sut.fetchClusters(
                selectedStartTime: Date(), selectedEndTime: Date(),
                topLeft: GeoPoint(latitude: 0, longitude: 0),
                bottomRight: GeoPoint(latitude: 0, longitude: 0),
                selectedActivityType: .running
            )
        }
        XCTAssertEqual(sut.fetchClustersCallCount, 2)
    }

    func test_fetchClusters_whenShouldThrow_throwsNSError() async {
        sut.shouldThrow = true
        do {
            _ = try await sut.fetchClusters(
                selectedStartTime: Date(), selectedEndTime: Date(),
                topLeft: GeoPoint(latitude: 0, longitude: 0),
                bottomRight: GeoPoint(latitude: 0, longitude: 0),
                selectedActivityType: .cycling
            )
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).domain, "MockError")
            XCTAssertEqual((error as NSError).code, 1)
        }
    }

    func test_fetchClusters_emptyStub_returnsEmptyArray() async throws {
        sut.stubbedClusters = []
        let results = try await sut.fetchClusters(
            selectedStartTime: Date(), selectedEndTime: Date(),
            topLeft: GeoPoint(latitude: 0, longitude: 0),
            bottomRight: GeoPoint(latitude: 0, longitude: 0),
            selectedActivityType: .running
        )
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: fetchIndividuals

    func test_fetchIndividuals_success_returnsExpectedData() async throws {
        sut.stubbedIndividuals = [
            AnchorAvailabilityEvent(eventId: "ev-1", event: MockAvailabilityEvent(id: "ev-1"))
        ]

        let results = try await sut.fetchIndividuals(
            in: makeRegion(),
            selectedStartDateTime: Date(),
            selectedEndDateTime: Date().addingTimeInterval(3600),
            selectedActivityType: .running
        )

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, "ev-1")
    }

    func test_fetchIndividuals_incrementsCallCount() async throws {
        _ = try await sut.fetchIndividuals(
            in: makeRegion(), selectedStartDateTime: Date(),
            selectedEndDateTime: Date(), selectedActivityType: .running
        )
        XCTAssertEqual(sut.fetchIndividualsCallCount, 1)
    }

    func test_fetchIndividuals_whenShouldThrow_throwsNSError() async {
        sut.shouldThrow = true
        do {
            _ = try await sut.fetchIndividuals(
                in: makeRegion(), selectedStartDateTime: Date(),
                selectedEndDateTime: Date(), selectedActivityType: .gym
            )
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertEqual((error as NSError).domain, "MockError")
            XCTAssertEqual((error as NSError).code, 2)
        }
    }

    func test_fetchIndividuals_emptyStub_returnsEmptyArray() async throws {
        sut.stubbedIndividuals = []
        let results = try await sut.fetchIndividuals(
            in: makeRegion(), selectedStartDateTime: Date(),
            selectedEndDateTime: Date(), selectedActivityType: .running
        )
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Helper

    private func makeRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45, longitude: 9),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}

// MARK: - LocationManager Tests
// LocationManager uses `private override init()` (singleton pattern) so it cannot be
// subclassed. Tests work directly on LocationManager.shared.
//
// RECOMMENDED PRODUCTION CHANGE: Extract a `LocationManaging` protocol and inject it
// into AvailbilityViewModel, allowing a lightweight stub in tests.

final class LocationManagerTests: XCTestCase {

    func test_shared_isNotNil() {
        XCTAssertNotNil(LocationManager.shared)
    }

    func test_userLocation_afterSettingValue_returnsCorrectCoordinates() throws {
        let expected = CLLocationCoordinate2D(latitude: 45.46, longitude: 9.19)
        LocationManager.shared.userLocation = expected

        // XCTUnwrap fails the test gracefully if the optional is nil
        let actual = try XCTUnwrap(LocationManager.shared.userLocation)
        XCTAssertEqual(actual.latitude,  expected.latitude,  accuracy: 0.0001)
        XCTAssertEqual(actual.longitude, expected.longitude, accuracy: 0.0001)
    }

    func test_userLocation_canBeSetToNil() {
        LocationManager.shared.userLocation = nil
        XCTAssertNil(LocationManager.shared.userLocation)
    }

    func test_requestPermission_doesNotCrash() {
        LocationManager.shared.requestPermission()
    }

    func test_startAndStopUpdating_doNotCrash() {
        LocationManager.shared.startUpdating()
        LocationManager.shared.stopUpdating()
    }
}

// MARK: - MKCoordinateRegion Extension Tests (topLeft / bottomRight)

final class MKCoordinateRegionExtensionTests: XCTestCase {

    private let center = CLLocationCoordinate2D(latitude: 45.0, longitude: 9.0)
    private let span   = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 2.0)

    func test_topLeft_isNorthWestCorner() {
        let region = MKCoordinateRegion(center: center, span: span)
        XCTAssertEqual(region.topLeft.latitude,  center.latitude  + span.latitudeDelta  / 2, accuracy: 0.0001)
        XCTAssertEqual(region.topLeft.longitude, center.longitude - span.longitudeDelta / 2, accuracy: 0.0001)
    }

    func test_bottomRight_isSouthEastCorner() {
        let region = MKCoordinateRegion(center: center, span: span)
        XCTAssertEqual(region.bottomRight.latitude,  center.latitude  - span.latitudeDelta  / 2, accuracy: 0.0001)
        XCTAssertEqual(region.bottomRight.longitude, center.longitude + span.longitudeDelta / 2, accuracy: 0.0001)
    }

    func test_topLeft_withZeroSpan_equalsCenter() {
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0))
        XCTAssertEqual(region.topLeft.latitude,  center.latitude,  accuracy: 0.0001)
        XCTAssertEqual(region.topLeft.longitude, center.longitude, accuracy: 0.0001)
    }

    func test_bottomRight_withZeroSpan_equalsCenter() {
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0))
        XCTAssertEqual(region.bottomRight.latitude,  center.latitude,  accuracy: 0.0001)
        XCTAssertEqual(region.bottomRight.longitude, center.longitude, accuracy: 0.0001)
    }

    func test_topLeftLatitude_isAlwaysGreaterThan_bottomRightLatitude() {
        let region = MKCoordinateRegion(center: center, span: span)
        XCTAssertGreaterThan(region.topLeft.latitude, region.bottomRight.latitude)
    }

    func test_topLeftLongitude_isAlwaysLessThan_bottomRightLongitude() {
        let region = MKCoordinateRegion(center: center, span: span)
        XCTAssertLessThan(region.topLeft.longitude, region.bottomRight.longitude)
    }
}
