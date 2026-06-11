//
//  ViewModelSearchEventsTests.swift
//  sbudTests
//

import XCTest
import MapKit
import FirebaseFirestore
@testable import sbud

// MARK: - Mock

final class MockSearchRequester: SearchEventRequesting {
    var callCount = 0
    var lastRequestType: SearchEventRequestType?
    var stubbedResult: Result<SearchEventResponse, Error> = .success(
        SearchEventResponse(events: [], page: 1, pageSize: 20,
                            totalCount: 0, totalPages: 1, hasNext: false, hasPrevious: false)
    )

    func search(requestType: SearchEventRequestType) async throws -> SearchEventResponse {
        callCount += 1
        lastRequestType = requestType
        switch stubbedResult {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }
}

// MARK: - Fixtures

private func makeSearchItem(id: String = UUID().uuidString) -> SearchEventResponseItem {
    let json = """
    {"title":"Run","eventImage":"","activityType":"Running",
     "startDateTime":0,"endDateTime":3600,"isDateConfirmed":false,
     "isPublic":true,"eventId":"\(id)"}
    """.data(using: .utf8)!
    return try! JSONDecoder().decode(SearchEventResponseItem.self, from: json)
}

private func makeResponse(items: [SearchEventResponseItem] = [], hasNext: Bool = false) -> SearchEventResponse {
    SearchEventResponse(events: items, page: 1, pageSize: 20,
                        totalCount: items.count, totalPages: 1,
                        hasNext: hasNext, hasPrevious: false)
}

private func makeRegion() -> MKCoordinateRegion {
    MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45, longitude: 9),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
}

// MARK: - Tests

@MainActor
final class ViewModelSearchEventsTests: XCTestCase {

    private var mockRequester: MockSearchRequester!
    private var sut: ViewModelSearchEvents!

    override func setUp() {
        super.setUp()
        mockRequester = MockSearchRequester()
        sut = ViewModelSearchEvents(region: makeRegion(), requester: mockRequester)
    }

    override func tearDown() {
        sut = nil
        mockRequester = nil
        super.tearDown()
    }

    // MARK: - Init

    func test_init_useFilters_falseWhenNoFilterResults() {
        XCTAssertFalse(sut.useFilters)
    }

    func test_init_useFilters_trueWhenFilterResultsProvided() {
        let vm = ViewModelSearchEvents(
            region: makeRegion(),
            filterResults: AvailabilityFiltersResults(),
            requester: mockRequester
        )
        XCTAssertTrue(vm.useFilters)
    }

    func test_init_searchResultsEmpty() {
        XCTAssertTrue(sut.searchResults.isEmpty)
    }

    func test_init_isLoadingFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    func test_init_hasNextPageFalse() {
        XCTAssertFalse(sut.hasNextPage)
    }

    // MARK: - performSearch — empty query

    func test_performSearch_emptyQuery_doesNotCallRequester() async {
        sut.searchQuery = ""
        await sut.performSearch()
        XCTAssertEqual(mockRequester.callCount, 0)
    }

    func test_performSearch_emptyQuery_clearsResults() async {
        mockRequester.stubbedResult = .success(makeResponse(items: [makeSearchItem()]))
        sut.searchQuery = "run"
        await sut.performSearch()
        sut.searchQuery = ""
        await sut.performSearch()
        XCTAssertTrue(sut.searchResults.isEmpty)
    }

    func test_performSearch_emptyQuery_resetsPageToOne() async {
        sut.searchQuery = "run"
        await sut.performSearch()
        sut.searchQuery = ""
        await sut.performSearch()
        XCTAssertEqual(sut.currentPage, 1)
    }

    // MARK: - performSearch — with query

    func test_performSearch_withQuery_callsRequesterOnce() async {
        sut.searchQuery = "marathon"
        await sut.performSearch()
        XCTAssertEqual(mockRequester.callCount, 1)
    }

    func test_performSearch_resetsToPageOne() async {
        sut.searchQuery = "run"
        await sut.performSearch()
        await sut.performSearch() // second search resets page
        XCTAssertEqual(sut.currentPage, 1)
    }

    func test_performSearch_resultsPopulated() async {
        mockRequester.stubbedResult = .success(makeResponse(items: [makeSearchItem(), makeSearchItem()]))
        sut.searchQuery = "run"
        await sut.performSearch()
        XCTAssertEqual(sut.searchResults.count, 2)
    }

    func test_performSearch_isLoadingFalseAfter() async {
        sut.searchQuery = "run"
        await sut.performSearch()
        XCTAssertFalse(sut.isLoading)
    }

    func test_performSearch_setsHasNextPage() async {
        mockRequester.stubbedResult = .success(makeResponse(items: [makeSearchItem()], hasNext: true))
        sut.searchQuery = "run"
        await sut.performSearch()
        XCTAssertTrue(sut.hasNextPage)
    }

    // MARK: - performSearch — page 1 replaces, page 2+ appends

    func test_performSearch_page1_replacesResults() async {
        mockRequester.stubbedResult = .success(makeResponse(items: [makeSearchItem(), makeSearchItem()], hasNext: true))
        sut.searchQuery = "run"
        await sut.performSearch()

        // Second search resets page to 1 and replaces
        mockRequester.stubbedResult = .success(makeResponse(items: [makeSearchItem()]))
        await sut.performSearch()
        XCTAssertEqual(sut.searchResults.count, 1)
    }

    func test_loadMoreResults_appendsResults() async {
        mockRequester.stubbedResult = .success(makeResponse(items: [makeSearchItem()], hasNext: true))
        sut.searchQuery = "run"
        await sut.performSearch()
        let afterPage1 = sut.searchResults.count

        mockRequester.stubbedResult = .success(makeResponse(items: [makeSearchItem(), makeSearchItem()], hasNext: false))
        await sut.loadMoreResults()
        XCTAssertEqual(sut.searchResults.count, afterPage1 + 2)
    }

    // MARK: - loadMoreResults guard

    func test_loadMoreResults_whenHasNextPageFalse_doesNotCallRequester() async {
        sut.searchQuery = "run"
        await sut.performSearch() // hasNextPage stays false from default stub
        let countAfter = mockRequester.callCount

        await sut.loadMoreResults()
        XCTAssertEqual(mockRequester.callCount, countAfter)
    }

    func test_loadMoreResults_incrementsPage() async {
        mockRequester.stubbedResult = .success(makeResponse(items: [makeSearchItem()], hasNext: true))
        sut.searchQuery = "run"
        await sut.performSearch()
        let pageBefore = sut.currentPage

        mockRequester.stubbedResult = .success(makeResponse(items: [makeSearchItem()]))
        await sut.loadMoreResults()
        XCTAssertEqual(sut.currentPage, pageBefore + 1)
    }

    // MARK: - Error handling

    func test_performSearch_onError_setsShowAlert() async {
        mockRequester.stubbedResult = .failure(URLError(.notConnectedToInternet))
        sut.searchQuery = "run"
        await sut.performSearch()
        XCTAssertTrue(sut.showAlert)
        XCTAssertFalse(sut.alertMsg.isEmpty)
    }

    func test_performSearch_onError_isLoadingFalse() async {
        mockRequester.stubbedResult = .failure(URLError(.notConnectedToInternet))
        sut.searchQuery = "run"
        await sut.performSearch()
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - toggleFilterMode

    func test_toggleFilterMode_togglesUseFilters() {
        let before = sut.useFilters
        sut.toggleFilterMode()
        XCTAssertNotEqual(sut.useFilters, before)
    }

    func test_toggleFilterMode_clearsResults() async {
        mockRequester.stubbedResult = .success(makeResponse(items: [makeSearchItem()]))
        sut.searchQuery = "run"
        await sut.performSearch()
        XCTAssertFalse(sut.searchResults.isEmpty)

        sut.toggleFilterMode()
        XCTAssertTrue(sut.searchResults.isEmpty)
    }

    func test_toggleFilterMode_resetsPageToOne() async {
        mockRequester.stubbedResult = .success(makeResponse(items: [makeSearchItem()], hasNext: true))
        sut.searchQuery = "run"
        await sut.performSearch()
        await sut.loadMoreResults()

        sut.toggleFilterMode()
        XCTAssertEqual(sut.currentPage, 1)
    }

    // MARK: - basic vs filtered request type

    func test_performSearch_withoutFilters_usesBasicEndpoint() async {
        sut.searchQuery = "run"
        await sut.performSearch()
        if case .basic = mockRequester.lastRequestType! {
            // correct
        } else {
            XCTFail("Expected .basic request type")
        }
    }

    func test_performSearch_withFilters_usesFilteredEndpoint() async {
        let vm = ViewModelSearchEvents(
            region: makeRegion(),
            filterResults: AvailabilityFiltersResults(),
            requester: mockRequester
        )
        vm.searchQuery = "run"
        await vm.performSearch()
        if case .filtered = mockRequester.lastRequestType! {
            // correct
        } else {
            XCTFail("Expected .filtered request type")
        }
    }
}
