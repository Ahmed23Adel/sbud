//
//  MockSearchEventRequester.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 11/07/2026.
//


import XCTest
import MapKit
import FirebaseFirestore
@testable import sbud

// MARK: - Mock

final class MockSearchEventRequester: SearchEventRequesting {
    var responseToReturn: SearchEventResponse!
    var shouldThrow = false
    private(set) var searchCallCount = 0
    private(set) var lastRequestType: SearchEventRequestType?

    func search(requestType: SearchEventRequestType) async throws -> SearchEventResponse {
        searchCallCount += 1
        lastRequestType = requestType
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        return responseToReturn
    }
}

// MARK: - Tests

@MainActor
final class ViewModelSearchEventsTests: XCTestCase {

    private var requester: MockSearchEventRequester!

    override func setUp() {
        super.setUp()
        requester = MockSearchEventRequester()
    }

    private var testRegion: MKCoordinateRegion {
        MKCoordinateRegion(center: .init(latitude: 45.0, longitude: 9.0),
                           span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }

    private func makeSUT(filters: AvailabilityFiltersResults? = nil) -> ViewModelSearchEvents {
        ViewModelSearchEvents(region: testRegion, filterResults: filters, requester: requester)
    }

    private func makeItem(id: String) -> SearchEventResponseItem {
            let json = """
            {"title": "Evento \(id)", "eventImage": "", "activityType": "Running",
             "startDateTime": 1000, "endDateTime": 2000, "eventId": "\(id)"}
            """.data(using: .utf8)!
            return try! JSONDecoder().decode(SearchEventResponseItem.self, from: json)
        }

        private func makeResponse(count: Int, hasNext: Bool) -> SearchEventResponse {
            let json = """
            {"events": [], "has_next": \(hasNext)}
            """.data(using: .utf8)!
            var response = try! JSONDecoder().decode(SearchEventResponse.self, from: json)
            // events è let: ricostruiamo via JSON completo
            let eventsJson = (0..<count).map { i in
                "{\"title\": \"Evento \(i)\", \"activityType\": \"Running\", \"startDateTime\": 1000, \"endDateTime\": 2000, \"eventId\": \"result_\(i)\"}"
            }.joined(separator: ",")
            let full = """
            {"events": [\(eventsJson)], "has_next": \(hasNext)}
            """.data(using: .utf8)!
            response = try! JSONDecoder().decode(SearchEventResponse.self, from: full)
            return response
        }

    // MARK: - Init

    func test_init_withoutFilters_useFiltersFalse() {
        XCTAssertFalse(makeSUT().useFilters)
    }

    func test_init_withFilters_useFiltersTrue() {
        XCTAssertTrue(makeSUT(filters: AvailabilityFiltersResults()).useFilters)
    }

    // MARK: - performSearch

    func test_performSearch_emptyQuery_clearsResults_andDoesNotCallRequester() async {
        let sut = makeSUT()
        sut.searchResults = [] // stato qualunque
        sut.searchQuery = ""

        await sut.performSearch()

        XCTAssertTrue(sut.searchResults.isEmpty)
        XCTAssertEqual(sut.currentPage, 1)
        XCTAssertEqual(requester.searchCallCount, 0)
    }

    func test_performSearch_basicMode_sendsBasicRequest() async {
        requester.responseToReturn = makeResponse(count: 2, hasNext: false)
        let sut = makeSUT()
        sut.searchQuery = "padel"

        await sut.performSearch()

        XCTAssertEqual(sut.searchResults.count, 2)
        XCTAssertFalse(sut.isLoading)
        if case .basic(let query, let page, _) = requester.lastRequestType {
            XCTAssertEqual(query, "padel")
            XCTAssertEqual(page, 1)
        } else {
            XCTFail("Senza filtri deve usare la richiesta basic")
        }
    }

    func test_performSearch_filteredMode_sendsFilteredRequest_withRegionCorners() async {
        requester.responseToReturn = makeResponse(count: 1, hasNext: false)
        let sut = makeSUT(filters: AvailabilityFiltersResults())
        sut.searchQuery = "corsa"

        await sut.performSearch()

        if case .filtered(let topLeft, let bottomRight, _, _, _, let query, _, let page, _) = requester.lastRequestType {
            XCTAssertEqual(query, "corsa")
            XCTAssertEqual(page, 1)
            XCTAssertEqual(topLeft.latitude, 45.1, accuracy: 0.0001)
            XCTAssertEqual(topLeft.longitude, 8.9, accuracy: 0.0001)
            XCTAssertEqual(bottomRight.latitude, 44.9, accuracy: 0.0001)
            XCTAssertEqual(bottomRight.longitude, 9.1, accuracy: 0.0001)
        } else {
            XCTFail("Con filtri deve usare la richiesta filtered")
        }
    }

    func test_performSearch_resetsPageToOne() async {
        requester.responseToReturn = makeResponse(count: 1, hasNext: true)
        let sut = makeSUT()
        sut.searchQuery = "x"
        sut.currentPage = 7

        await sut.performSearch()

        XCTAssertEqual(sut.currentPage, 1)
    }

    func test_performSearch_error_showsAlert() async {
        requester.shouldThrow = true
        let sut = makeSUT()
        sut.searchQuery = "x"

        await sut.performSearch()

        XCTAssertTrue(sut.showAlert)
        XCTAssertFalse(sut.alertMsg.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Paginazione

    func test_loadMoreResults_appendsToExisting() async {
        requester.responseToReturn = makeResponse(count: 2, hasNext: true)
        let sut = makeSUT()
        sut.searchQuery = "x"
        await sut.performSearch()
        XCTAssertEqual(sut.searchResults.count, 2)

        requester.responseToReturn = makeResponse(count: 2, hasNext: false)
        await sut.loadMoreResults()

        XCTAssertEqual(sut.searchResults.count, 4, "Pagina 2 si aggiunge, non sostituisce")
        XCTAssertEqual(sut.currentPage, 2)
        XCTAssertFalse(sut.hasNextPage)
        XCTAssertFalse(sut.isLoadingNewPage)
    }

    func test_loadMoreResults_noNextPage_doesNothing() async {
        requester.responseToReturn = makeResponse(count: 1, hasNext: false)
        let sut = makeSUT()
        sut.searchQuery = "x"
        await sut.performSearch()
        let callsBefore = requester.searchCallCount

        await sut.loadMoreResults()

        XCTAssertEqual(requester.searchCallCount, callsBefore)
        XCTAssertEqual(sut.currentPage, 1)
    }

    // MARK: - toggleFilterMode

    func test_toggleFilterMode_flipsFlag_andClearsResults() {
        let sut = makeSUT(filters: AvailabilityFiltersResults())
        sut.searchResults = []
        XCTAssertTrue(sut.useFilters)

        sut.toggleFilterMode()

        XCTAssertFalse(sut.useFilters)
        XCTAssertTrue(sut.searchResults.isEmpty)
        XCTAssertEqual(sut.currentPage, 1)
    }

    func test_toggleFilterMode_withQuery_triggersNewSearch() async throws {
        requester.responseToReturn = makeResponse(count: 1, hasNext: false)
        let sut = makeSUT(filters: AvailabilityFiltersResults())
        sut.searchQuery = "padel"
        await sut.performSearch()
        let before = requester.searchCallCount

        sut.toggleFilterMode()
        // la ricerca parte in un Task interno
        for _ in 0..<30 {
            if requester.searchCallCount > before { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }

        XCTAssertGreaterThan(requester.searchCallCount, before)
        if case .basic = requester.lastRequestType {} else {
            XCTFail("Dopo il toggle (filtri OFF) la nuova ricerca deve essere basic")
        }
    }
}

// MARK: - SearchEventRequestType + decoding

final class SearchEventModelsTests: XCTestCase {

    // toDict

    func test_basic_toDict_containsQueryAndPaging() {
        let dict = SearchEventRequestType.basic(query: "padel", page: 2, pageSize: 20).toDict()
        XCTAssertEqual(dict["query"], "padel")
        XCTAssertEqual(dict["page"], "2")
        XCTAssertEqual(dict["page_size"], "20")
        XCTAssertNil(dict["selectedActivityType"])
    }

    func test_filtered_toDict_containsCoordinatesAndMergesExtraFilters() {
        let type = SearchEventRequestType.filtered(
            topLeft: .init(latitude: 45.1, longitude: 8.9),
            bottomRight: .init(latitude: 44.9, longitude: 9.1),
            activityType: "Running",
            startTime: Date(timeIntervalSince1970: 0),
            endTime: Date(timeIntervalSince1970: 3600),
            query: "corsa",
            extraFilters: ["minProposedDistance": "5.0"],
            page: 1, pageSize: 20
        )

        let dict = type.toDict()

        XCTAssertEqual(dict["topLeftLatitude"], "45.1")
        XCTAssertEqual(dict["bottomRightLongitude"], "9.1")
        XCTAssertEqual(dict["selectedActivityType"], "Running")
        XCTAssertEqual(dict["query"], "corsa")
        XCTAssertEqual(dict["minProposedDistance"], "5.0", "Gli extraFilters vanno mergiati")
        XCTAssertNotNil(dict["selectedStartTime"])
    }

    func test_endpoints_differPerType() {
        XCTAssertEqual(SearchEventRequestType.basic(query: "", page: 1, pageSize: 1).endpoint,
                       "events/search/title")
        let filtered = SearchEventRequestType.filtered(
            topLeft: .init(latitude: 0, longitude: 0), bottomRight: .init(latitude: 0, longitude: 0),
            activityType: "", startTime: Date(), endTime: Date(), query: "",
            extraFilters: [:], page: 1, pageSize: 1)
        XCTAssertEqual(filtered.endpoint, "events/search/filtered")
    }

    // Decoder custom di SearchEventResponseItem

    private func decodeItem(_ json: String) throws -> SearchEventResponseItem {
        try JSONDecoder().decode(SearchEventResponseItem.self, from: json.data(using: .utf8)!)
    }

    func test_decode_usesEventId_whenPresent() throws {
        let item = try decodeItem("""
        {"title": "T", "activityType": "Gym", "eventId": "filtered_id",
         "startDateTime": 1000, "endDateTime": 2000}
        """)
        XCTAssertEqual(item.eventId, "filtered_id")
        XCTAssertNil(item.id)
    }

    func test_decode_fallsBackToId_whenEventIdMissing() throws {
        let item = try decodeItem("""
        {"title": "T", "activityType": "Gym", "id": "basic_id",
         "startDateTime": 1000, "endDateTime": 2000}
        """)
        XCTAssertEqual(item.eventId, "basic_id")
        XCTAssertEqual(item.id, "basic_id")
    }

    func test_decode_missingBothIds_throws() {
        XCTAssertThrowsError(try decodeItem("""
        {"title": "T", "activityType": "Gym", "startDateTime": 1000, "endDateTime": 2000}
        """))
    }

    func test_decode_defaults_applied() throws {
        let item = try decodeItem("""
        {"title": "T", "activityType": "Gym", "eventId": "e1",
         "startDateTime": 1000, "endDateTime": 2000}
        """)
        XCTAssertEqual(item.eventImage, "")
        XCTAssertFalse(item.isDateConfirmed)
        XCTAssertTrue(item.isPublic)
    }

    func test_decode_timestampsMapped() throws {
        let item = try decodeItem("""
        {"title": "T", "activityType": "Gym", "eventId": "e1",
         "startDateTime": 1000, "endDateTime": 2000}
        """)
        XCTAssertEqual(item.startDateTime, Date(timeIntervalSince1970: 1000))
        XCTAssertEqual(item.endDateTime, Date(timeIntervalSince1970: 2000))
    }

    // toSearchEventResult

    func test_toSearchEventResult_mapsFieldsWithFallbacks() throws {
        let item = try decodeItem("""
        {"title": "Corsa", "activityType": "Running", "eventId": "e1",
         "startDateTime": 1000, "endDateTime": 2000}
        """)

        let result = item.toSearchEventResult()

        XCTAssertEqual(result.id, "e1", "Senza id deve usare eventId")
        XCTAssertEqual(result.creatorName, "Unknown", "Senza creator deve usare il fallback")
        XCTAssertEqual(result.numFlattenedEvents, 1, "Default a 1 senza NumFlattenedEvents")
    }

    func test_toSearchEventResult_prefersIdOverEventId() throws {
        let item = try decodeItem("""
        {"title": "T", "activityType": "Gym", "eventId": "evt", "id": "doc_id",
         "startDateTime": 1000, "endDateTime": 2000, "NumFlattenedEvents": 3}
        """)

        let result = item.toSearchEventResult()

        XCTAssertEqual(result.id, "doc_id")
        XCTAssertEqual(result.eventId, "evt")
        XCTAssertEqual(result.numFlattenedEvents, 3)
    }
}
