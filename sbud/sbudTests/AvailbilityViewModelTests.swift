//
//  AvailbilityViewModelTests.swift
//  sbudTests
//

import XCTest
import SwiftUI
import MapKit
import FirebaseFirestore
@testable import sbud

// MARK: - MockLocationProvider

final class MockLocationProvider: LocationProviding {
    var userLocation: CLLocationCoordinate2D?
    var requestPermissionCallCount = 0

    func requestPermission() {
        requestPermissionCallCount += 1
    }
}

// MARK: - MockDataFetcher

final class MockDataFetcher: AvailabilityDataFetching {
    var fetchIndividualsCallCount = 0
    var fetchClustersCallCount = 0
    var lastFetchClustersActivityType: ActivityType?

    var stubbedIndividualsResult: Result<[AnchorAvailabilityEvent], Error> = .success([])
    var stubbedClustersResult: Result<[AnchorCluster], Error> = .success([])

    func fetchIndividuals(
        in region: MKCoordinateRegion,
        selectedStartDateTime: Date,
        selectedEndDateTime: Date,
        selectedActivityType: ActivityType,
        extraFilters: [String: String]
    ) async throws -> [AnchorAvailabilityEvent] {
        fetchIndividualsCallCount += 1
        switch stubbedIndividualsResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }

    func fetchClusters(
        selectedStartTime: Date,
        selectedEndTime: Date,
        topLeft: GeoPoint,
        bottomRight: GeoPoint,
        selectedActivityType: ActivityType,
        extraFilters: [String: String]
    ) async throws -> [AnchorCluster] {
        fetchClustersCallCount += 1
        lastFetchClustersActivityType = selectedActivityType
        switch stubbedClustersResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }
}

// MARK: - Tests

final class AvailbilityViewModelTests: XCTestCase {

    private var mockLocation: MockLocationProvider!
    private var mockFetcher: MockDataFetcher!
    private var filters: AvailabilityFiltersResults!
    private var sut: AvailbilityViewModel!

    override func setUp() {
        super.setUp()
        mockLocation = MockLocationProvider()
        mockFetcher  = MockDataFetcher()
        filters      = AvailabilityFiltersResults()
        sut = AvailbilityViewModel(
            locationProvider: mockLocation,
            availabilityFiltersResults: filters,
            dataFetcher: mockFetcher
        )
    }

    override func tearDown() {
        sut          = nil
        filters      = nil
        mockFetcher  = nil
        mockLocation = nil
        super.tearDown()
    }

    // MARK: - Init

    func test_init_callsRequestPermission() {
        XCTAssertEqual(mockLocation.requestPermissionCallCount, 1)
    }

    func test_init_defaultSelectedTabIsZero() {
        XCTAssertEqual(sut.selectedTab, 0)
    }

    func test_init_defaultPrecisionIsNeighbourhood() {
        XCTAssertEqual(sut.currentCameraPrecision, .neighbourhood)
    }

    func test_init_cameraIsNotAutomatic() {
        // VM always sets a region on init — never leaves it as .automatic
        XCTAssertNotEqual(sut.cameraPosition, .automatic)
    }

    func test_init_withKnownUserLocation_cameraIsNotAutomatic() {
        let loc = MockLocationProvider()
        loc.userLocation = CLLocationCoordinate2D(latitude: 45.0, longitude: 9.0)
        let vm = AvailbilityViewModel(
            locationProvider: loc,
            availabilityFiltersResults: AvailabilityFiltersResults(),
            dataFetcher: mockFetcher
        )
        XCTAssertNotEqual(vm.cameraPosition, .automatic)
    }

    func test_init_withNilUserLocation_cameraIsNotAutomatic() {
        mockLocation.userLocation = nil
        let vm = AvailbilityViewModel(
            locationProvider: mockLocation,
            availabilityFiltersResults: AvailabilityFiltersResults(),
            dataFetcher: mockFetcher
        )
        XCTAssertNotEqual(vm.cameraPosition, .automatic)
    }

    // MARK: - zoomToCity

    func test_zoomToCity_withExplicitCenter_changesCameraPosition() {
        let before = sut.cameraPosition
        sut.zoomToCity(center: CLLocationCoordinate2D(latitude: 48.0, longitude: 2.0))
        XCTAssertNotEqual(sut.cameraPosition, before)
    }

    func test_zoomToCity_calledTwice_withDifferentCenters_updatesCameraEachTime() {
        sut.zoomToCity(center: CLLocationCoordinate2D(latitude: 48.0, longitude: 2.0))
        let afterFirst = sut.cameraPosition
        sut.zoomToCity(center: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.1))
        XCTAssertNotEqual(sut.cameraPosition, afterFirst)
    }

    func test_zoomToCity_withNoArgsAndNilLocation_doesNotCrash() {
        mockLocation.userLocation = nil
        sut.zoomToCity()
        XCTAssertNotEqual(sut.cameraPosition, .automatic)
    }

    // MARK: - handleMapCameraChange — first call (nil guard path)

    func test_handleMapCameraChange_firstRegion_setsCurrentRegion() {
        XCTAssertNil(sut.currentRegion)
        sut.handleMapCameraChange(makeRegion(latDelta: 0.5))
        XCTAssertNotNil(sut.currentRegion)
    }

    func test_handleMapCameraChange_cityLevel_setsShowIndividualsFalse() {
        sut.handleMapCameraChange(makeRegion(latDelta: 0.5)) // largeCity
        XCTAssertFalse(sut.shouldShowIndividuals)
    }

    func test_handleMapCameraChange_individualsLevel_setsShowIndividualsTrue() {
        sut.handleMapCameraChange(makeRegion(latDelta: 0.01))
        XCTAssertTrue(sut.shouldShowIndividuals)
    }

    func test_handleMapCameraChange_updatesCurrentCameraPrecision() {
        sut.handleMapCameraChange(makeRegion(latDelta: 2.0)) // country
        XCTAssertEqual(sut.currentCameraPrecision, .country)
    }

    func test_handleMapCameraChange_updatesCurrentRegion() {
        let region = makeRegion(center: CLLocationCoordinate2D(latitude: 48, longitude: 2), latDelta: 0.5)
        sut.handleMapCameraChange(region)
        XCTAssertEqual(sut.currentRegion?.center.latitude ?? 0, 48, accuracy: 0.001)
    }

    // MARK: - handleMapCameraChange — containment de-dup

    func test_handleMapCameraChange_containedRegion_doesNotTriggerAnotherFetch() {
        // Establish large region first
        let old = makeRegion(center: CLLocationCoordinate2D(latitude: 45, longitude: 9), latDelta: 1.0)
        sut.handleMapCameraChange(old)
        let countAfterFirst = mockFetcher.fetchClustersCallCount

        // Pan within the same region — no new fetch expected
        let inner = makeRegion(center: CLLocationCoordinate2D(latitude: 45, longitude: 9), latDelta: 0.1)
        sut.handleMapCameraChange(inner)
        XCTAssertEqual(mockFetcher.fetchClustersCallCount, countAfterFirst)
    }

    func test_handleMapCameraChange_panOutside_triggersFetch() async throws {
        let old = makeRegion(center: CLLocationCoordinate2D(latitude: 45, longitude: 9), latDelta: 0.2)
        sut.handleMapCameraChange(old)
        try await Task.sleep(nanoseconds: 200_000_000) // let the Task from handleMapCameraChange run
        let countAfterFirst = mockFetcher.fetchClustersCallCount

        let far = makeRegion(center: CLLocationCoordinate2D(latitude: 55, longitude: 9), latDelta: 0.2)
        sut.handleMapCameraChange(far)
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertGreaterThan(mockFetcher.fetchClustersCallCount, countAfterFirst)
    }

    // MARK: - handleMapCameraChange — individuals de-dup

    func test_handleMapCameraChange_individualsAlreadyFetched_doesNotRefetch() {
        let individualRegion = makeRegion(latDelta: 0.01)
        sut.handleMapCameraChange(individualRegion) // first → fetches
        let countAfterFirst = mockFetcher.fetchIndividualsCallCount

        sut.handleMapCameraChange(individualRegion) // still individuals, already fetched
        XCTAssertEqual(mockFetcher.fetchIndividualsCallCount, countAfterFirst)
    }

    func test_handleMapCameraChange_switchFromCityToIndividuals_fetchesIndividuals() async throws {
        sut.handleMapCameraChange(makeRegion(latDelta: 0.5)) // clusters — sets currentRegion
        try await Task.sleep(nanoseconds: 200_000_000)
        let individualsCountBefore = mockFetcher.fetchIndividualsCallCount

        sut.handleMapCameraChange(makeRegion(latDelta: 0.01)) // zoom into individuals
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertGreaterThan(mockFetcher.fetchIndividualsCallCount, individualsCountBefore)
    }

    // MARK: - changeSelectedActivity

    func test_changeSelectedActivity_triggersFetch() async throws {
        try await Task.sleep(nanoseconds: 200_000_000) // let init's Task complete first
        let before = mockFetcher.fetchClustersCallCount
        sut.changeSelectedActivity(selectedActivityIndex: 3)
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertGreaterThan(mockFetcher.fetchClustersCallCount, before)
    }

    // MARK: - updateListId

    func test_updateListId_changesRefreshId() {
        let before = sut.listViewRefreshId
        sut.updateListId()
        XCTAssertNotEqual(sut.listViewRefreshId, before)
    }

    func test_updateListId_calledTwice_generatesDifferentIds() {
        sut.updateListId()
        let mid = sut.listViewRefreshId
        sut.updateListId()
        XCTAssertNotEqual(sut.listViewRefreshId, mid)
    }

    // MARK: - Error state — clusters

    func test_fetchClusters_onError_setsShowErrorAlert() async throws {
        mockFetcher.stubbedClustersResult = .failure(URLError(.notConnectedToInternet))
        sut.handleMapCameraChange(makeRegion(latDelta: 0.5))
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(sut.showErrorAlert)
        XCTAssertFalse(sut.alertMsg.isEmpty)
    }

    func test_fetchClusters_errorAlertSetOnlyOnce_subsequentErrorsDoNotOverwrite() async throws {
        mockFetcher.stubbedClustersResult = .failure(URLError(.notConnectedToInternet))

        sut.handleMapCameraChange(makeRegion(latDelta: 0.5))
        try await Task.sleep(nanoseconds: 200_000_000)
        let firstMsg = sut.alertMsg

        // Second fetch error with alert already shown — message must not change
        let far = makeRegion(center: CLLocationCoordinate2D(latitude: 55, longitude: 9), latDelta: 0.5)
        sut.handleMapCameraChange(far)
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.alertMsg, firstMsg)
    }

    // MARK: - Error state — individuals

    func test_fetchIndividuals_onError_setsShowErrorAlert() async throws {
        mockFetcher.stubbedIndividualsResult = .failure(URLError(.notConnectedToInternet))
        // Force precision to individuals so fetchNewData takes the individual path
        sut.currentCameraPrecision = .individuals
        sut.currentRegion = makeRegion(latDelta: 0.01)
        sut.handleMapCameraChange(makeRegion(latDelta: 0.01))
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(sut.showErrorAlert)
        XCTAssertFalse(sut.alertMsg.isEmpty)
    }

    func test_fetchIndividuals_errorMsgDiffersFromClustersMsg() async throws {
        // Clusters error first
        mockFetcher.stubbedClustersResult = .failure(URLError(.notConnectedToInternet))
        sut.handleMapCameraChange(makeRegion(latDelta: 0.5))
        try await Task.sleep(nanoseconds: 200_000_000)
        let clustersMsg = sut.alertMsg

        // Reset and fire individuals error
        let sut2 = AvailbilityViewModel(
            locationProvider: MockLocationProvider(),
            availabilityFiltersResults: AvailabilityFiltersResults(),
            dataFetcher: {
                let m = MockDataFetcher()
                m.stubbedIndividualsResult = .failure(URLError(.notConnectedToInternet))
                return m
            }()
        )
        sut2.currentCameraPrecision = .individuals
        sut2.currentRegion = makeRegion(latDelta: 0.01)
        sut2.handleMapCameraChange(makeRegion(latDelta: 0.01))
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertNotEqual(clustersMsg, sut2.alertMsg)
    }

    // MARK: - Helpers

    private func makeRegion(latDelta: Double) -> MKCoordinateRegion {
        makeRegion(
            center: CLLocationCoordinate2D(latitude: 45, longitude: 9),
            latDelta: latDelta
        )
    }

    private func makeRegion(center: CLLocationCoordinate2D, latDelta: Double) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: latDelta)
        )
    }
}
