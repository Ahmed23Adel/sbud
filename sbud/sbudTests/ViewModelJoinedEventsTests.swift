//
//  ViewModelJoinedEventsTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

@MainActor
final class ViewModelJoinedEventsTests: XCTestCase {

    private var mockFetcher: MockJoinedEventsFetching!
    private var mockProvider: MockCurrentUserProvider!
    private var sut: ViewModelJoinedEvents!

    override func setUp() {
        super.setUp()
        mockFetcher = MockJoinedEventsFetching()
        mockProvider = MockCurrentUserProvider()
        mockProvider.currentUserId = "me"
        sut = ViewModelJoinedEvents(fetcher: mockFetcher, currentUserProvider: mockProvider, autoStart: false)
    }

    override func tearDown() {
        sut = nil; mockProvider = nil; mockFetcher = nil
        super.tearDown()
    }

    func test_init_participatedEventsStartEmpty() {
        XCTAssertTrue(sut.participatedEvents.isEmpty)
    }

    func test_load_populatesEvents() async {
        mockFetcher.stubbedResult = .success([.fixture(eventId: "j1", status: .confirmed)])
        await sut.load()
        XCTAssertEqual(sut.participatedEvents.map(\.eventId), ["j1"])
    }

    func test_load_passesCurrentUserId() async {
        await sut.load()
        XCTAssertEqual(mockFetcher.lastUserId, "me")
    }

    func test_load_whenNotAuthenticated_doesNotFetch() async {
        mockProvider.currentUserId = nil
        await sut.load()
        XCTAssertNil(mockFetcher.lastUserId)
        XCTAssertTrue(sut.participatedEvents.isEmpty)
    }

    func test_load_onError_setsAlert() async {
        mockFetcher.stubbedResult = .failure(URLError(.notConnectedToInternet))
        await sut.load()
        XCTAssertTrue(sut.isShowAlert)
    }

    func test_sections_groupsByStatusInOrder() async {
        mockFetcher.stubbedResult = .success([
            .fixture(eventId: "j1", status: .confirmed),
            .fixture(eventId: "j2", status: .completed)
        ])
        await sut.load()
        let first = sut.sections.first?.0
        let last  = sut.sections.last?.0
        XCTAssertEqual(first, .confirmed)
        XCTAssertEqual(last, .completed)
    }
}
