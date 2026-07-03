//
//  ViewModelFlattenedEventsListTests.swift
//  sbudTests
//

import XCTest
import MapKit
@testable import sbud

// MARK: - Mock

final class MockPaginatedRequester: PaginatedFlattenedEventsRequesting {
    var callCount = 0
    var stubbedResult: Result<PaginatedEventDetailsResponse, Error> = .success(
        PaginatedEventDetailsResponse(events: [], page: 1, pageSize: 10,
                                      totalCount: 0, totalPages: 1,
                                      hasNext: false, hasPrevious: false)
    )

    func fetchEvents(requestParams: PaginatedFlattenedEventsRequest) async throws -> PaginatedEventDetailsResponse {
        callCount += 1
        switch stubbedResult {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }
}

// MARK: - Helpers

private func makeResponse(
    events: [PaginatedEvent] = [],
    hasNext: Bool = false,
    page: Int = 1
) -> PaginatedEventDetailsResponse {
    PaginatedEventDetailsResponse(
        events: events,
        page: page,
        pageSize: 10,
        totalCount: events.count,
        totalPages: 1,
        hasNext: hasNext,
        hasPrevious: false
    )
}

private func makePaginatedEvent(id: String = UUID().uuidString) -> PaginatedEvent {
    PaginatedEvent(
        createdAt: 0,
        endDateTime: Date().timeIntervalSince1970 + 3600,
        startDateTime: Date().timeIntervalSince1970,
        isDateConfirmed: true,
        isPublic: true,
        isLocationConfirmed: true,
        eventId: id,
        eventImage: "",
        activityType: .running,
        creatorName: "Test",
        numFlattenedEvents: 1,
        title: "Event \(id)"
    )
}

private func makeRegion() -> MKCoordinateRegion {
    MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45, longitude: 9),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
}

// MARK: - Tests

final class ViewModelFlattenedEventsListTests: XCTestCase {

    private var mockRequester: MockPaginatedRequester!
    private var filters: AvailabilityFiltersResults!

    override func setUp() {
        super.setUp()
        mockRequester = MockPaginatedRequester()
        filters = AvailabilityFiltersResults()
    }

    override func tearDown() {
        mockRequester = nil
        filters = nil
        super.tearDown()
    }

    private func makeSUT() -> ViewModelFlattenedEventsList {
        ViewModelFlattenedEventsList(
            region: makeRegion(),
            filterResults: filters,
            requester: mockRequester
        )
    }

    // MARK: - Initial load

    func test_init_callsRequesterOnce() async throws {
        _ = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(mockRequester.callCount, 1)
    }

    func test_init_isLoadingFalseAfterLoad() async throws {
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.isLoading)
    }

    func test_init_startsWithPageOne() {
        let sut = makeSUT()
        XCTAssertEqual(sut.currentPage, 1)
    }

    func test_init_successResponse_populatesEvents() async throws {
        mockRequester.stubbedResult = .success(makeResponse(events: [makePaginatedEvent(), makePaginatedEvent()]))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.events.count, 2)
    }

    func test_init_successResponse_incrementsPage() async throws {
        mockRequester.stubbedResult = .success(makeResponse(events: [makePaginatedEvent()]))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.currentPage, 2)
    }

    func test_init_hasNextTrue_canLoadMoreIsTrue() async throws {
        mockRequester.stubbedResult = .success(makeResponse(events: [makePaginatedEvent()], hasNext: true))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(sut.canLoadMore)
    }

    func test_init_hasNextFalse_canLoadMoreIsFalse() async throws {
        mockRequester.stubbedResult = .success(makeResponse(events: [makePaginatedEvent()], hasNext: false))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.canLoadMore)
    }

    // MARK: - Error state

    func test_init_error_setsShowAlert() async throws {
        mockRequester.stubbedResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(sut.showAlert)
    }

    func test_init_error_setsAlertMsg() async throws {
        mockRequester.stubbedResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.alertMsg.isEmpty)
    }

    func test_init_error_canLoadMoreIsFalse() async throws {
        mockRequester.stubbedResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.canLoadMore)
    }

    // MARK: - loadEventsPaginnated guard

    func test_loadEventsPaginnated_whenCannotLoadMore_doesNotCallRequester() async throws {
        mockRequester.stubbedResult = .success(makeResponse(hasNext: false))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        let countAfterInit = mockRequester.callCount

        sut.loadEventsPaginnated() // canLoadMore is false after hasNext=false
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(mockRequester.callCount, countAfterInit)
    }

    // MARK: - Pagination — second page appends

    func test_loadEventsPaginnated_appendsToExistingEvents() async throws {
        mockRequester.stubbedResult = .success(makeResponse(events: [makePaginatedEvent()], hasNext: true))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        let countAfterPage1 = sut.events.count

        // Now fetch page 2
        mockRequester.stubbedResult = .success(makeResponse(events: [makePaginatedEvent(), makePaginatedEvent()], hasNext: false))
        sut.loadEventsPaginnated()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(sut.events.count, countAfterPage1 + 2)
    }

    func test_loadEventsPaginnated_incrementsPage() async throws {
        mockRequester.stubbedResult = .success(makeResponse(events: [makePaginatedEvent()], hasNext: true))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        let pageAfterFirst = sut.currentPage

        mockRequester.stubbedResult = .success(makeResponse(events: [makePaginatedEvent()], hasNext: false))
        sut.loadEventsPaginnated()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(sut.currentPage, pageAfterFirst + 1)
    }
}
