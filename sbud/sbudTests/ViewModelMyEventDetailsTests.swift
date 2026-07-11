//
//  ViewModelMyEventDetailsTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

@MainActor
final class ViewModelMyEventDetailsTests: XCTestCase {

    private var mockEventFetcher: MockEventFetcher!
    private var mockJoinRequester: MockJoinRequester!
    private var mockDeleter: MockEventDeleting!
    private var sut: ViewModelMyEventDetails!

    override func setUp() {
        super.setUp()
        mockEventFetcher = MockEventFetcher()
        mockJoinRequester = MockJoinRequester()
        mockDeleter = MockEventDeleting()
        PopUpGenerator.shared.clearAll()
        sut = ViewModelMyEventDetails(
            eventId: "evt1",
            eventFetcher: mockEventFetcher,
            joinRequester: mockJoinRequester,
            deleteRequester: mockDeleter,
            autoStart: false
        )
    }

    override func tearDown() {
        PopUpGenerator.shared.clearAll()
        sut = nil; mockDeleter = nil; mockJoinRequester = nil; mockEventFetcher = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func test_init_isLoadingFalse() { XCTAssertFalse(sut.isLoading) }
    func test_init_noDetails()      { XCTAssertNil(sut.myEventDertails) }
    func test_init_eventIdSet()     { XCTAssertEqual(sut.eventId, "evt1") }

    // MARK: - loadDetails

    func test_loadDetails_setsEventDetails() async {
        mockEventFetcher.stubbedResult = .success(.fixture(id: "evt1"))
        await sut.loadDetails()
        XCTAssertNotNil(sut.myEventDertails)
        let id = sut.myEventDertails?.id ?? ""
        XCTAssertEqual(id, "evt1")
    }

    func test_loadDetails_setsIsLoadingFalseAfterSuccess() async {
        mockEventFetcher.stubbedResult = .success(.fixture())
        await sut.loadDetails()
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadDetails_setsIsLoadingFalseAfterFailure() async {
        mockEventFetcher.stubbedResult = .failure(URLError(.notConnectedToInternet))
        await sut.loadDetails()
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadDetails_onFailure_showsErrorToast() async throws {
        mockEventFetcher.stubbedResult = .failure(URLError(.notConnectedToInternet))
        await sut.loadDetails()
        try await Task.sleep(nanoseconds: 150_000_000)
        let animName = PopUpGenerator.shared.popUps.first?.type.animationName ?? ""
        XCTAssertEqual(animName, "alert")
    }

    // MARK: - respondToRequest

    func test_respondToRequest_accept_incrementsConfirmedCount() async {
        sut.queueResponse = .fixture(pendingUserIds: ["r1"], confirmedCount: 2)
        mockJoinRequester.stubbedQueueResult = .success(.fixture(pendingUserIds: [], confirmedCount: 3))
        await sut.respondToRequest(requesterId: "r1", accept: true)
        let count = sut.queueResponse?.confirmedCount ?? 0
        XCTAssertEqual(count, 3)
        let stillPending = sut.queueResponse?.pendingUsers.contains { $0.userId == "r1" } ?? false
        XCTAssertFalse(stillPending)
    }

    func test_respondToRequest_reject_decrementsPendingCount() async {
        sut.queueResponse = .fixture(pendingUserIds: ["r1"], confirmedCount: 2)
        await sut.respondToRequest(requesterId: "r1", accept: false)
        let count = sut.queueResponse?.pendingCount ?? -1
        XCTAssertEqual(count, 0)
    }

    func test_respondToRequest_accept_showsConfirmedToast() async throws {
        sut.queueResponse = .fixture(pendingUserIds: ["r1"])
        await sut.respondToRequest(requesterId: "r1", accept: true)
        try await Task.sleep(nanoseconds: 150_000_000)
        let msg = PopUpGenerator.shared.popUps.first?.msg ?? ""
        XCTAssertEqual(msg, "Confirmed")
    }

    func test_respondToRequest_reject_showsRejectedToast() async throws {
        sut.queueResponse = .fixture(pendingUserIds: ["r1"])
        await sut.respondToRequest(requesterId: "r1", accept: false)
        try await Task.sleep(nanoseconds: 150_000_000)
        let msg = PopUpGenerator.shared.popUps.first?.msg ?? ""
        XCTAssertEqual(msg, "Rejected.")
    }

    // MARK: - deleteEvent

    func test_deleteEvent_onSuccess_setsEventDeleted() async {
        await sut.deleteEvent()
        XCTAssertTrue(sut.eventDeleted)
        XCTAssertFalse(sut.isDeletingEvent)
        XCTAssertEqual(mockDeleter.lastEventId, "evt1")
    }

    func test_deleteEvent_onFailure_doesNotSetEventDeleted() async {
        mockDeleter.stubbedResult = .failure(URLError(.notConnectedToInternet))
        await sut.deleteEvent()
        XCTAssertFalse(sut.eventDeleted)
        XCTAssertFalse(sut.isDeletingEvent)
    }

    func test_deleteEvent_onSuccess_showsSuccessToast() async throws {
        await sut.deleteEvent()
        try await Task.sleep(nanoseconds: 150_000_000)
        let msg = PopUpGenerator.shared.popUps.first?.msg ?? ""
        XCTAssertEqual(msg, "Event deleted successfully")
    }

    func test_deleteEvent_onFailure_showsErrorToast() async throws {
        mockDeleter.stubbedResult = .failure(URLError(.notConnectedToInternet))
        await sut.deleteEvent()
        try await Task.sleep(nanoseconds: 150_000_000)
        let animName = PopUpGenerator.shared.popUps.first?.type.animationName ?? ""
        XCTAssertEqual(animName, "alert")
    }
}
