//
//  MockLocationProvider.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 10/07/2026.
//


import XCTest
import MapKit
import FirebaseFirestore
import CoreLocation
@testable import sbud

// MARK: - Mocks

final class MockLocationProvider: LocationProviding {
    var userLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 45.0, longitude: 9.0)
    private(set) var permissionRequested = false
    func requestPermission() { permissionRequested = true }
}

final class MockAvailabilityDataFetcher: AvailabilityDataFetching {
    var individualsToReturn: [AnchorAvailabilityEvent] = []
    var clustersToReturn: [AnchorCluster] = []
    var shouldThrow = false
    private(set) var fetchIndividualsCount = 0
    private(set) var fetchClustersCount = 0

    func fetchIndividuals(in region: MKCoordinateRegion, selectedStartDateTime: Date,
                          selectedEndDateTime: Date, selectedActivityType: ActivityType,
                          extraFilters: [String: String]) async throws -> [AnchorAvailabilityEvent] {
        fetchIndividualsCount += 1
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        return individualsToReturn
    }

    func fetchClusters(selectedStartTime: Date, selectedEndTime: Date, topLeft: GeoPoint,
                       bottomRight: GeoPoint, selectedActivityType: ActivityType,
                       extraFilters: [String: String]) async throws -> [AnchorCluster] {
        fetchClustersCount += 1
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        return clustersToReturn
    }
}

// MARK: - AvailbilityViewModel

@MainActor
final class AvailbilityViewModelTests: XCTestCase {

    private var location: MockLocationProvider!
    private var fetcher: MockAvailabilityDataFetcher!
    private var filters: AvailabilityFiltersResults!

    override func setUp() {
        super.setUp()
        location = MockLocationProvider()
        fetcher = MockAvailabilityDataFetcher()
        filters = AvailabilityFiltersResults()
    }

    private func makeSUT() -> AvailbilityViewModel {
        AvailbilityViewModel(locationProvider: location,
                             availabilityFiltersResults: filters,
                             dataFetcher: fetcher)
    }

    private func region(latDelta: Double, center: CLLocationCoordinate2D = .init(latitude: 45, longitude: 9)) -> MKCoordinateRegion {
        MKCoordinateRegion(center: center,
                           span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: latDelta))
    }

    private func settle() async { try? await Task.sleep(nanoseconds: 700_000_000) }

    func test_init_requestsPermission_andFetchesClusters() async {
        let sut = makeSUT()
        await settle()
        XCTAssertTrue(location.permissionRequested)
        XCTAssertGreaterThanOrEqual(fetcher.fetchClustersCount, 1)
        XCTAssertFalse(sut.shouldShowIndividuals)
    }

    func test_firstCameraChange_alwaysFetches() async {
        let sut = makeSUT()
        await settle()
        let before = fetcher.fetchClustersCount

        sut.handleMapCameraChange(region(latDelta: 0.1)) // city
        await settle()

        XCTAssertGreaterThan(fetcher.fetchClustersCount, before)
        XCTAssertEqual(sut.currentCameraPrecision, .city)
    }

    func test_zoomToIndividuals_switchesModeAndFetchesIndividuals() async {
        let sut = makeSUT()
        await settle()

        sut.handleMapCameraChange(region(latDelta: 0.1))   // prima regione (city)
        await settle()
        sut.handleMapCameraChange(region(latDelta: 0.005)) // zoom → individuals
        await settle()

        XCTAssertTrue(sut.shouldShowIndividuals)
        XCTAssertGreaterThanOrEqual(fetcher.fetchIndividualsCount, 1)
    }

    func test_containedRegion_doesNotRefetch() async {
        let sut = makeSUT()
        await settle()
        sut.handleMapCameraChange(region(latDelta: 0.5)) // largeCity, grande
        await settle()
        let before = fetcher.fetchClustersCount

        // Regione più piccola DENTRO la precedente, stessa fascia di precisione
        sut.handleMapCameraChange(region(latDelta: 0.3))
        await settle()

        XCTAssertEqual(fetcher.fetchClustersCount, before,
                       "Regione contenuta nella vecchia: non deve rifetchare")
    }

    func test_notContainedRegion_refetches() async {
        let sut = makeSUT()
        await settle()
        sut.handleMapCameraChange(region(latDelta: 0.3))
        await settle()
        let before = fetcher.fetchClustersCount

        // Stessa dimensione ma centro spostato lontano → non contenuta
        sut.handleMapCameraChange(region(latDelta: 0.3, center: .init(latitude: 50, longitude: 15)))
        await settle()

        XCTAssertGreaterThan(fetcher.fetchClustersCount, before)
    }

    func test_individualsToIndividuals_doesNotRefetch() async {
        let sut = makeSUT()
        await settle()
        sut.handleMapCameraChange(region(latDelta: 0.005))
        await settle()
        let before = fetcher.fetchIndividualsCount

        sut.handleMapCameraChange(region(latDelta: 0.004))
        await settle()

        XCTAssertEqual(fetcher.fetchIndividualsCount, before,
                       "Da individuals a individuals non deve rifetchare")
    }

    func test_fetchClustersError_showsAlert() async {
        fetcher.shouldThrow = true
        let sut = makeSUT()
        await settle()

        XCTAssertTrue(sut.showErrorAlert)
        XCTAssertFalse(sut.alertMsg.isEmpty)
    }

    func test_changeSelectedActivity_triggersFetch() async {
        let sut = makeSUT()
        await settle()
        let before = fetcher.fetchClustersCount

        sut.changeSelectedActivity(selectedActivityIndex: 2)
        await settle()

        XCTAssertGreaterThan(fetcher.fetchClustersCount, before)
    }

    func test_changingStartDate_triggersFetchViaListener() async {
        let sut = makeSUT()
        await settle()
        let before = fetcher.fetchClustersCount

        filters.startDateTime = Date().addingTimeInterval(3600)
        await settle()

        XCTAssertGreaterThan(fetcher.fetchClustersCount, before)
        _ = sut // tiene vivo il VM
    }

    func test_zoomToCity_usesProvidedCenter() {
        let sut = makeSUT()
        sut.zoomToCity(center: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5))
        // Non crasha e imposta una region: la verifica del centro esatto
        // richiederebbe l'accesso interno a MapCameraPosition
        XCTAssertNotNil(sut.cameraPosition)
    }

    func test_updateListId_changesId() {
        let sut = makeSUT()
        let before = sut.listViewRefreshId
        sut.updateListId()
        XCTAssertNotEqual(sut.listViewRefreshId, before)
    }
}

// MARK: - MapsHelper (logica pura)

final class MapsHelperTests: XCTestCase {

    let sut = MapsHelper()

    func test_determinePrecision_allBands() {
        func region(_ delta: Double) -> MKCoordinateRegion {
            MKCoordinateRegion(center: .init(latitude: 0, longitude: 0),
                               span: .init(latitudeDelta: delta, longitudeDelta: delta))
        }
        XCTAssertEqual(sut.determinePrecision(from: region(0.005)), .individuals)
        XCTAssertEqual(sut.determinePrecision(from: region(0.03)), .individuals)
        XCTAssertEqual(sut.determinePrecision(from: region(0.1)), .city)
        XCTAssertEqual(sut.determinePrecision(from: region(0.5)), .largeCity)
        XCTAssertEqual(sut.determinePrecision(from: region(3.0)), .country)
        XCTAssertEqual(sut.determinePrecision(from: region(20.0)), .continent)
    }

    func test_calcCenter_isMidpoint() {
        let center = sut.calcCenterForLoc(minLat: 10, maxLat: 20, minLon: 30, maxLon: 50)
        XCTAssertEqual(center.latitude, 15)
        XCTAssertEqual(center.longitude, 40)
    }

    func test_calcDelta_scalesByFactor() {
        let (lat, lon) = sut.calcDelta(maxLat: 11, minLat: 10, maxLon: 21, minLon: 20)
        XCTAssertEqual(lat, 1.3, accuracy: 0.0001)
        XCTAssertEqual(lon, 1.3, accuracy: 0.0001)
    }

    func test_calcDelta_neverBelowCityZoom() {
        let (lat, lon) = sut.calcDelta(maxLat: 10.001, minLat: 10, maxLon: 20.001, minLon: 20)
        XCTAssertEqual(lat, sut.cityZoomLatitudeDelta)
        XCTAssertEqual(lon, sut.cityZoomLongitudeDelta)
    }
}

// MARK: - AvailabilityFiltersResults (logica pura)

final class AvailabilityFiltersResultsTests: XCTestCase {

    func test_buildSearchPayload_running_includesBaseFields() {
        let sut = AvailabilityFiltersResults()
        sut.selectedActivityIndex = 0 // running (verifica l'ordine in AvailabilityConfig)

        let payload = sut.buildSearchPayload()

        XCTAssertEqual(payload["activity"] as? String, sut.selectedActivity.rawValue)
        XCTAssertNotNil(payload["startTime"])
        XCTAssertNotNil(payload["endTime"])
        XCTAssertNil(payload["gender"], "Senza gender il campo non deve esserci")
    }

    func test_buildSearchPayload_withGender_includesIt() {
        let sut = AvailabilityFiltersResults()
        sut.gender = GenderFilter.allCases.first

        let payload = sut.buildSearchPayload()

        XCTAssertNotNil(payload["gender"])
    }

    func test_buildExtraQueryParams_emptyFilters_returnsEmpty() {
        let sut = AvailabilityFiltersResults()
        let params = sut.buildExtraQueryParams()
        XCTAssertTrue(params.isEmpty)
    }

    func test_buildExtraQueryParams_runningFilters_mapped() {
        let sut = AvailabilityFiltersResults()
        sut.selectedActivityIndex = 0 // running
        sut.runningFilter.minDistanceInKm = 5
        sut.runningFilter.maxDistanceInKm = 10

        let params = sut.buildExtraQueryParams()

        XCTAssertEqual(params["minProposedDistance"], "5.0")
        XCTAssertEqual(params["maxProposedDistance"], "10.0")
    }

    func test_equatable_comparesKeyFields() {
        let a = AvailabilityFiltersResults()
        let b = AvailabilityFiltersResults()
        b.startDateTime = a.startDateTime
        b.endDateTime = a.endDateTime
        XCTAssertEqual(a, b)

        b.selectedActivityIndex = 3
        XCTAssertNotEqual(a, b)
    }
}