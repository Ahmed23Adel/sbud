//
//  ViewModelMyEventsTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

@MainActor
final class ViewModelMyEventsTests: XCTestCase {

    private var mockCreated: MockUsersEventFetching!
    private var mockHosting: MockHostingEventsFetching!
    private var sut: ViewModelMyEvents!

    override func setUp() {
        super.setUp()
        mockCreated = MockUsersEventFetching()
        mockHosting = MockHostingEventsFetching()
        sut = ViewModelMyEvents(userId: "me", createdEventsFetcher: mockCreated,
                                hostingEventsFetcher: mockHosting, autoStart: false)
    }

    override func tearDown() {
        sut = nil; mockHosting = nil; mockCreated = nil
        super.tearDown()
    }

    func test_init_collectionsStartEmpty() {
        XCTAssertTrue(sut.usersEvents.isEmpty)
        XCTAssertTrue(sut.hostingEvents.isEmpty)
        XCTAssertEqual(sut.selectedTab, .created)
    }

    // MARK: - loadCreatedEvents

    func test_loadCreatedEvents_populatesEvents() async {
        mockCreated.stubbedResult = .success([.fixture(eventId: "e1")])
        await sut.loadCreatedEvents()
        XCTAssertEqual(sut.usersEvents.map(\.eventId), ["e1"])
    }

    func test_loadCreatedEvents_passesUserId() async {
        await sut.loadCreatedEvents()
        XCTAssertEqual(mockCreated.lastUserId, "me")
    }

    func test_loadCreatedEvents_onError_setsAlert() async {
        mockCreated.stubbedResult = .failure(URLError(.notConnectedToInternet))
        await sut.loadCreatedEvents()
        XCTAssertTrue(sut.isShowAlert)
        XCTAssertFalse(sut.alertMsg.isEmpty)
    }

    func test_loadCreatedEvents_onError_preservesExistingData() async {
        mockCreated.stubbedResult = .success([.fixture(eventId: "keep")])
        await sut.loadCreatedEvents()
        mockCreated.stubbedResult = .failure(URLError(.timedOut))
        await sut.loadCreatedEvents()
        XCTAssertEqual(sut.usersEvents.map(\.eventId), ["keep"])
    }

    // MARK: - loadHostingEvents

    func test_loadHostingEvents_populatesEvents() async {
        mockHosting.stubbedResult = .success([.fixture(eventId: "h1")])
        await sut.loadHostingEvents()
        XCTAssertEqual(sut.hostingEvents.map(\.eventId), ["h1"])
    }

    func test_loadHostingEvents_setsIsLoadingFalse() async {
        await sut.loadHostingEvents()
        XCTAssertFalse(sut.isLoadingHosting)
    }

    func test_loadHostingEvents_onError_setsIsLoadingFalse() async {
        mockHosting.stubbedResult = .failure(URLError(.notConnectedToInternet))
        await sut.loadHostingEvents()
        XCTAssertFalse(sut.isLoadingHosting)
    }

    // MARK: - sections computed property

    func test_sections_groupsByStatusInOrder() async {
        mockCreated.stubbedResult = .success([
            .fixture(eventId: "e1", status: .confirmed),
            .fixture(eventId: "e2", status: .proposed),
            .fixture(eventId: "e3", status: .completed),
            .fixture(eventId: "e4", status: .confirmed)
        ])
        await sut.loadCreatedEvents()
        let statuses = sut.sections.map(\.0)
        XCTAssertEqual(statuses, [.confirmed, .proposed, .completed])
        let confirmedCount = sut.sections.first?.1.count ?? 0
        XCTAssertEqual(confirmedCount, 2)
    }

    func test_sections_emptyStatus_isOmitted() async {
        mockCreated.stubbedResult = .success([.fixture(eventId: "e1", status: .confirmed)])
        await sut.loadCreatedEvents()
        let statuses = sut.sections.map(\.0)
        XCTAssertFalse(statuses.contains(.proposed))
        XCTAssertFalse(statuses.contains(.completed))
    }

    // MARK: - hostingSections computed property

    func test_hostingSections_groupsCorrectly() async {
        mockHosting.stubbedResult = .success([
            .fixture(eventId: "h1", status: "Confirmed"),
            .fixture(eventId: "h2", status: "Proposed")
        ])
        await sut.loadHostingEvents()
        let statuses = sut.hostingSections.map(\.0)
        XCTAssertEqual(statuses, [.confirmed, .proposed])
    }
}
