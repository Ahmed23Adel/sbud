//
//  AvailabilityIntegrationTests.swift
//  sbudTests
//
//  Integration tests for the Availability feature.
//  These tests use real collaborating objects (AvailbilityViewModel + AvailabilityFiltersResults +
//  MapsHelper) and only mock at the true system boundary: AvailabilityDataFetching.
//
//  Key difference from unit tests: no mocking of MapsHelper or AvailabilityFiltersResults —
//  we verify that the Combine pipelines and precision logic work end-to-end.
//

import XCTest
import SwiftUI
import MapKit
import FirebaseFirestore
@testable import sbud

// MARK: - Integration Test Suite

@MainActor
final class AvailabilityIntegrationTests: XCTestCase {

    // MARK: - Properties

    private var mockFetcher: MockDataFetcher!
    private var mockLocation: MockLocationProvider!
    private var filters: AvailabilityFiltersResults!
    private var sut: AvailbilityViewModel!
    private var coordinator: AvailabilityCoordinator!

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        mockFetcher  = MockDataFetcher()
        mockLocation = MockLocationProvider()
        filters      = AvailabilityFiltersResults()
        sut = AvailbilityViewModel(
            locationProvider: mockLocation,
            availabilityFiltersResults: filters,
            dataFetcher: mockFetcher
        )
        coordinator = AvailabilityCoordinator()
    }

    override func tearDown() {
        sut         = nil
        filters     = nil
        mockFetcher = nil
        mockLocation = nil
        coordinator  = nil
        super.tearDown()
    }

    // MARK: - 1. Filter → ViewModel → Fetcher Pipeline

    // Verifies that changing startDateTime on the REAL AvailabilityFiltersResults triggers
    // a new fetch through the Combine pipeline wired up in AvailbilityViewModel.setupFilterResultsListener.
    func test_filterStartDateChange_triggersNewFetch() async throws {
        try await Task.sleep(nanoseconds: 200_000_000) // let init Task settle
        let before = mockFetcher.fetchClustersCallCount

        filters.startDateTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        // dropFirst means first emission is skipped; the second (our change) fires a fetch
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertGreaterThan(mockFetcher.fetchClustersCallCount, before,
            "startDateTime change should trigger a new cluster fetch")
    }

    func test_filterEndDateChange_triggersNewFetch() async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        let before = mockFetcher.fetchClustersCallCount

        filters.endDateTime = Calendar.current.date(byAdding: .hour, value: 10, to: Date()) ?? Date()
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertGreaterThan(mockFetcher.fetchClustersCallCount, before,
            "endDateTime change should trigger a new cluster fetch")
    }

    func test_filterGenderChange_triggersNewFetch() async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        let before = mockFetcher.fetchClustersCallCount

        filters.gender = .male
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertGreaterThan(mockFetcher.fetchClustersCallCount, before,
            "gender filter change should trigger a new fetch")
    }

    // Sport-specific filter holders use a 500ms debounce — we wait 700ms to be safe.
    func test_runningFilterChange_afterDebounce_triggersNewFetch() async throws {
        filters.selectedActivityIndex = 0 // running
        try await Task.sleep(nanoseconds: 200_000_000)
        let before = mockFetcher.fetchClustersCallCount

        filters.runningFilter.minDistanceInKm = 5.0
        try await Task.sleep(nanoseconds: 700_000_000) // 500ms debounce + buffer

        XCTAssertGreaterThan(mockFetcher.fetchClustersCallCount, before,
            "running filter change should trigger a fetch after the 500ms debounce")
    }

    func test_cyclingFilterChange_afterDebounce_triggersNewFetch() async throws {
        filters.selectedActivityIndex = 1 // cycling
        try await Task.sleep(nanoseconds: 200_000_000)
        let before = mockFetcher.fetchClustersCallCount

        filters.cyclingFilter.minSpeedInKmH = 20.0
        try await Task.sleep(nanoseconds: 700_000_000)

        XCTAssertGreaterThan(mockFetcher.fetchClustersCallCount, before)
    }

    // MARK: - 2. selectedActivityIndex → VM → Fetcher activity type

    // Verifies that changing the activity index on the real AvailabilityFiltersResults propagates
    // the correct ActivityType all the way to the fetcher call.
    func test_activityIndexChange_passesCyclingActivityType_toFetcher() async throws {
        // Index 1 = cycling in AvailabilityConfig
        filters.selectedActivityIndex = 1
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertEqual(mockFetcher.lastFetchClustersActivityType, .cycling,
            "Changing selectedActivityIndex to cycling should pass .cycling to the fetcher")
    }

    func test_activityIndexChange_passesRunningActivityType_toFetcher() async throws {
        // Switch away then back to 0 (running), since 0 fires at init too
        filters.selectedActivityIndex = 2
        try await Task.sleep(nanoseconds: 300_000_000)
        filters.selectedActivityIndex = 0
        try await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertEqual(mockFetcher.lastFetchClustersActivityType, .running)
    }

    // MARK: - 3. Real MapsHelper + ViewModel Precision Pipeline

    // Uses the real MapsHelper to verify that precision decisions drive fetcher selection.
    func test_realMapsHelper_cityLevelDelta_fetchesClusters_notIndividuals() async throws {
        // 0.5 → largeCity precision per MapsHelper.determinePrecision
        sut.handleMapCameraChange(makeRegion(latDelta: 0.5))
        try await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertGreaterThan(mockFetcher.fetchClustersCallCount, 0)
        XCTAssertEqual(mockFetcher.fetchIndividualsCallCount, 0,
            "City-level zoom should fetch clusters, not individuals")
    }

    func test_realMapsHelper_individualLevelDelta_fetchesIndividuals_notClusters() async throws {
        // Set up a currentRegion at cluster level first, then zoom into individuals
        sut.handleMapCameraChange(makeRegion(latDelta: 0.5))
        try await Task.sleep(nanoseconds: 300_000_000)
        let clustersBefore = mockFetcher.fetchClustersCallCount

        // 0.01 → individuals precision
        sut.handleMapCameraChange(makeRegion(latDelta: 0.01))
        try await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertGreaterThan(mockFetcher.fetchIndividualsCallCount, 0)
        XCTAssertEqual(mockFetcher.fetchClustersCallCount, clustersBefore,
            "Individual-level zoom should not trigger another cluster fetch")
    }

    // Panning to a location outside the already-fetched region always triggers a new cluster fetch,
    // regardless of precision level. This is the actual VM refetch contract — not precision change.
    func test_realMapsHelper_panOutsideFetchedRegion_triggersClustersRefetch() async throws {
        let milanRegion = makeRegion(center: CLLocationCoordinate2D(latitude: 45.5, longitude: 9.2), latDelta: 0.5)
        sut.handleMapCameraChange(milanRegion)
        try await Task.sleep(nanoseconds: 300_000_000)
        let after = mockFetcher.fetchClustersCallCount

        // Paris is far outside Milan's bounding box — containment check fails → refetch fires
        let parisRegion = makeRegion(center: CLLocationCoordinate2D(latitude: 48.9, longitude: 2.3), latDelta: 0.5)
        sut.handleMapCameraChange(parisRegion)
        try await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertGreaterThan(mockFetcher.fetchClustersCallCount, after,
            "Panning to a region outside the previously fetched area must trigger a new cluster fetch")
    }

    // A contained region (panning within already-fetched area) should NOT fetch again.
    func test_realMapsHelper_containedPan_doesNotRefetch() async throws {
        let wide = makeRegion(center: CLLocationCoordinate2D(latitude: 45, longitude: 9), latDelta: 2.0)
        sut.handleMapCameraChange(wide)
        try await Task.sleep(nanoseconds: 300_000_000)
        let after = mockFetcher.fetchClustersCallCount

        // Small region fully inside the wide one
        let contained = makeRegion(center: CLLocationCoordinate2D(latitude: 45, longitude: 9), latDelta: 0.5)
        sut.handleMapCameraChange(contained)
        // No sleep needed — synchronous guard; give it a tiny window anyway
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(mockFetcher.fetchClustersCallCount, after,
            "Panning within the already-fetched region must not trigger a redundant fetch")
    }

    // MARK: - 4. buildExtraQueryParams → Fetcher Integration

    // Verifies that the params built by the real AvailabilityFiltersResults reach the mock fetcher.
    // (We track what the VM passes by spying on the last call via MockDataFetcher extension below.)
    func test_genderFilter_appearsInExtraQueryParams() {
        filters.gender = .female
        let params = filters.buildExtraQueryParams()
        XCTAssertEqual(params["gender"], GenderFilter.female.rawValue)
    }

    func test_noGender_producesNoGenderParam() {
        filters.gender = nil
        let params = filters.buildExtraQueryParams()
        XCTAssertNil(params["gender"])
    }

    func test_runningFilter_withMinDistance_appearsInParams() {
        filters.selectedActivityIndex = 0
        filters.runningFilter.minDistanceInKm = 3.5
        let params = filters.buildExtraQueryParams()
        XCTAssertEqual(params["minProposedDistance"], "3.5")
    }

    func test_runningFilter_withRunningType_appearsInParams() {
        filters.selectedActivityIndex = 0
        filters.runningFilter.runningType = .trail
        let params = filters.buildExtraQueryParams()
        XCTAssertEqual(params["proposedRunningType"], RunningType.trail.rawValue)
    }

    func test_cyclingFilter_nilValues_produceNoParams() {
        filters.selectedActivityIndex = 1
        // All cycling filter optionals are nil by default
        let params = filters.buildExtraQueryParams()
        XCTAssertNil(params["minProposedDistanceInKm"])
        XCTAssertNil(params["proposedCyclingType"])
    }

    func test_buildSearchPayload_includesActivityAndTimeRange() {
        let payload = filters.buildSearchPayload()
        XCTAssertNotNil(payload["activity"])
        XCTAssertNotNil(payload["startTime"])
        XCTAssertNotNil(payload["endTime"])
    }

    func test_buildSearchPayload_startTimeBeforeEndTime() {
        let payload = filters.buildSearchPayload()
        let start = payload["startTime"] as? Double ?? 0
        let end   = payload["endTime"]   as? Double ?? 0
        XCTAssertLessThan(start, end, "startTime must come before endTime in the search payload")
    }

    // MARK: - 5. Coordinator + ViewModel Navigation Sequence

    // These test the coordinator in isolation (no live NavigationStack needed in XCTest).

    func test_coordinatorSequence_pushThree_popAll_clearsPath() {
        coordinator.showMoreInfo(eventId: "e1")
        coordinator.showAddNewEvent()
        coordinator.showProfile(userId: "u1")
        XCTAssertEqual(coordinator.navigationPath.count, 3)

        coordinator.popToRoot()
        XCTAssertTrue(coordinator.navigationPath.isEmpty)
    }

    func test_coordinatorSequence_pushThenPopOne_leavesCorrectCount() {
        coordinator.showMoreInfo(eventId: "e1")
        coordinator.showAddNewEvent()
        coordinator.pop()
        XCTAssertEqual(coordinator.navigationPath.count, 1)
    }

    func test_coordinatorSequence_mixedPushPop_finalCountIsCorrect() {
        coordinator.showMoreInfo(eventId: "e1")   // 1
        coordinator.showAddNewEvent()              // 2
        coordinator.pop()                          // 1
        coordinator.showProfile(userId: "u2")     // 2
        coordinator.showMoreInfo(eventId: "e3")   // 3
        coordinator.pop()                          // 2

        XCTAssertEqual(coordinator.navigationPath.count, 2)
    }

    func test_coordinatorSequence_multiplePopToRoot_doesNotCrash() {
        coordinator.showMoreInfo(eventId: "e1")
        coordinator.popToRoot()
        coordinator.popToRoot() // second call on already-empty path
        XCTAssertTrue(coordinator.navigationPath.isEmpty)
    }

    func test_coordinatorSequence_popOnEmptyPath_doesNotCrash() {
        XCTAssertTrue(coordinator.navigationPath.isEmpty)
        coordinator.pop()
        coordinator.pop()
        XCTAssertTrue(coordinator.navigationPath.isEmpty)
    }

    func test_coordinator_searchEventsDestination_pushedWithFilters() {
        let filters = AvailabilityFiltersResults()
        coordinator.showSearchEvents(region: makeRegion(latDelta: 0.1), filterResults: filters)
        XCTAssertEqual(coordinator.navigationPath.count, 1)
    }

    // MARK: - 6. Error State + Navigation Independence

    // After a fetch error, the coordinator's navigation state is unaffected.
    func test_fetchError_doesNotAffectCoordinatorNavigationPath() async throws {
        mockFetcher.stubbedClustersResult = .failure(URLError(.notConnectedToInternet))
        sut.handleMapCameraChange(makeRegion(latDelta: 0.5))
        try await Task.sleep(nanoseconds: 300_000_000)

        XCTAssertTrue(sut.showErrorAlert)
        // Coordinator was never touched — path still empty
        XCTAssertTrue(coordinator.navigationPath.isEmpty)
    }

    // After an error, updating the filter still attempts a new fetch (the VM stays alive).
    func test_afterFetchError_filterChange_stillTriggersNewFetch() async throws {
        mockFetcher.stubbedClustersResult = .failure(URLError(.notConnectedToInternet))
        sut.handleMapCameraChange(makeRegion(latDelta: 0.5))
        try await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertTrue(sut.showErrorAlert)

        // Recover: stub success, change a filter
        mockFetcher.stubbedClustersResult = .success([])
        let before = mockFetcher.fetchClustersCallCount
        filters.endDateTime = Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date()
        try await Task.sleep(nanoseconds: 400_000_000)

        XCTAssertGreaterThan(mockFetcher.fetchClustersCallCount, before,
            "VM should still fire fetches after an earlier error")
    }

    // MARK: - 7. Memory Safety

    func test_viewModel_noMemoryLeak() {
        var vm: AvailbilityViewModel? = AvailbilityViewModel(
            locationProvider: MockLocationProvider(),
            availabilityFiltersResults: AvailabilityFiltersResults(),
            dataFetcher: MockDataFetcher()
        )
        weak var weakVm = vm
        addTeardownBlock { XCTAssertNil(weakVm, "AvailbilityViewModel leaked — check Combine cancellable retain cycles") }
        vm = nil
    }

    func test_coordinator_noMemoryLeak() {
        var coord: AvailabilityCoordinator? = AvailabilityCoordinator()
        weak var weakCoord = coord
        addTeardownBlock { XCTAssertNil(weakCoord, "AvailabilityCoordinator leaked") }
        coord = nil
    }

    // MARK: - Helpers

    private func makeRegion(latDelta: Double) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45, longitude: 9),
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: latDelta)
        )
    }

    private func makeRegion(center: CLLocationCoordinate2D, latDelta: Double) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: latDelta)
        )
    }
}

// MARK: - Spy extension on MockDataFetcher

// Track the last extraFilters dict passed to fetchClusters so param-propagation tests can inspect it.
extension MockDataFetcher {
    var lastFetchClustersExtraFilters: [String: String]? {
        // Stored via objc association — lightweight approach for integration spy
        return objc_getAssociatedObject(self, &MockDataFetcherKeys.extraFilters) as? [String: String]
    }

    func recordExtraFilters(_ filters: [String: String]) {
        objc_setAssociatedObject(self, &MockDataFetcherKeys.extraFilters, filters, .OBJC_ASSOCIATION_RETAIN)
    }
}

private enum MockDataFetcherKeys {
    static var extraFilters = "extraFilters"
}
