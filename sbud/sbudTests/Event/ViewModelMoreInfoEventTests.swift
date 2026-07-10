//
//  ViewModelMoreInfoEventTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 10/07/2026.
//


import XCTest
@testable import sbud

@MainActor
final class ViewModelMoreInfoEventTests: XCTestCase {

    private var mockJoin: MockJoinRequester!
    private var mockFetcher: MockEventFetcher!
    private var mockProvider: MockCurrentUserProvider!

    override func setUp() {
        super.setUp()
        mockJoin = MockJoinRequester()
        mockFetcher = MockEventFetcher()
        mockProvider = MockCurrentUserProvider()
        mockProvider.currentUserId = "viewer"
        PopUpGenerator.shared.clearAll()
    }

    override func tearDown() {
        PopUpGenerator.shared.clearAll()
        mockProvider = nil; mockFetcher = nil; mockJoin = nil
        super.tearDown()
    }

    private func makeSUT() -> ViewModelMoreInfoEvent {
        ViewModelMoreInfoEvent(
            eventId: "evt1",
            joinRequester: mockJoin,
            eventFetcher: mockFetcher,
            currentUserProvider: mockProvider
        )
    }

    // L'init lancia loadDetails in un Task: aspettiamo che finisca
    private func waitForLoad(_ sut: ViewModelMoreInfoEvent) async throws {
        for _ in 0..<50 {
            if sut.fullDetails != nil || sut.isErrorLoading { return }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        XCTFail("loadDetails non è mai terminato")
    }

    // MARK: - JoinState (enum puro, copre tutto il file di stato)

    func test_joinState_isDisabled() {
        XCTAssertFalse(JoinState.idle.isDisabled)
        XCTAssertFalse(JoinState.withdrawn.isDisabled)
        XCTAssertFalse(JoinState.rejected.isDisabled)
        XCTAssertTrue(JoinState.pending.isDisabled)
        XCTAssertTrue(JoinState.confirmed.isDisabled)
        XCTAssertTrue(JoinState.full.isDisabled)
        XCTAssertTrue(JoinState.waitlisted(position: 2).isDisabled)
    }

    func test_joinState_labelText() {
        XCTAssertEqual(JoinState.idle.labelText, "Join Activity")
        XCTAssertEqual(JoinState.withdrawn.labelText, "Join Activity")
        XCTAssertEqual(JoinState.pending.labelText, "Request Sent")
        XCTAssertEqual(JoinState.waitlisted(position: 3).labelText, "Waitlist #3")
        XCTAssertEqual(JoinState.confirmed.labelText, "Joined ✓")
        XCTAssertEqual(JoinState.rejected.labelText, "Rejected")
        XCTAssertEqual(JoinState.full.labelText, "Event Full")
    }

    func test_joinState_iconName_coversAllCases() {
        XCTAssertEqual(JoinState.idle.iconName, "door.left.hand.open")
        XCTAssertEqual(JoinState.pending.iconName, "clock")
        XCTAssertEqual(JoinState.waitlisted(position: 1).iconName, "list.number")
        XCTAssertEqual(JoinState.confirmed.iconName, "checkmark.circle.fill")
        XCTAssertEqual(JoinState.full.iconName, "person.fill.xmark")
    }

    func test_joinState_canLeave_onlyWhenConfirmed() {
        XCTAssertTrue(JoinState.confirmed.canLeave)
        XCTAssertFalse(JoinState.pending.canLeave)
        XCTAssertFalse(JoinState.idle.canLeave)
    }

    func test_joinState_canWithdraw_pendingAndWaitlisted() {
        XCTAssertTrue(JoinState.pending.canWithdraw)
        XCTAssertTrue(JoinState.waitlisted(position: 5).canWithdraw)
        XCTAssertFalse(JoinState.confirmed.canWithdraw)
        XCTAssertFalse(JoinState.idle.canWithdraw)
    }

    // MARK: - loadDetails

    func test_loadDetails_success_setsDetailsAndStopsLoading() async throws {
        mockFetcher.stubbedResult = .success(.fixture(id: "evt1"))
        let sut = makeSUT()

        try await waitForLoad(sut)

        XCTAssertEqual(sut.fullDetails?.id, "evt1")
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.isErrorLoading)
    }

    func test_loadDetails_viewerIsNotCreator_isCurrentUserHostFalse_andLoadsMyStatus() async throws {
        mockFetcher.stubbedResult = .success(.fixture(id: "evt1")) // creator = .sample, non "viewer"
        mockJoin.stubbedMyStatusResult = .success(MyStatusResponse(status: "pending", waitlistPosition: nil))
        let sut = makeSUT()

        try await waitForLoad(sut)
        try await Task.sleep(nanoseconds: 500_000_000) // tempo per loadMyStatus

        XCTAssertFalse(sut.isCurrentUserHost)
        XCTAssertEqual(sut.joinState, .pending)
    }

    func test_loadDetails_viewerIsCreator_isHost_andLoadsQueue() async throws {
        var event = EventFullDetails.fixture(id: "evt1")
        event.creator = CreatorInfo(id: "viewer", name: "Io", surName: "Test", profileImageUrl: nil)
        mockFetcher.stubbedResult = .success(event)
        mockJoin.stubbedQueueResult = .success(.fixture(pendingUserIds: ["p1"], confirmedCount: 4))
        let sut = makeSUT()

        try await waitForLoad(sut)
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertTrue(sut.isCurrentUserHost)
        XCTAssertEqual(sut.queueResponse?.confirmedCount, 4)
    }

    func test_loadDetails_failure_setsErrorFlag() async throws {
        mockFetcher.stubbedResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT()

        try await waitForLoad(sut)

        XCTAssertTrue(sut.isErrorLoading)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.fullDetails)
    }

    // MARK: - loadMyStatus (mapping stati)

    func test_loadMyStatus_mapsAllServerStates() async throws {
        mockFetcher.stubbedResult = .success(.fixture(id: "evt1"))
        let sut = makeSUT()
        try await waitForLoad(sut)

        let cases: [(String, JoinState)] = [
            ("pending", .pending),
            ("confirmed", .confirmed),
            ("rejected", .rejected),
            ("withdrawn", .withdrawn),
            ("left", .withdrawn),
            ("qualcosa_di_ignoto", .idle)
        ]
        for (server, expected) in cases {
            mockJoin.stubbedMyStatusResult = .success(MyStatusResponse(status: server, waitlistPosition: nil))
            await sut.loadMyStatus()
            XCTAssertEqual(sut.joinState, expected, "status server '\(server)'")
        }
    }

    func test_loadMyStatus_waitlisted_carriesPosition() async throws {
        mockFetcher.stubbedResult = .success(.fixture(id: "evt1"))
        let sut = makeSUT()
        try await waitForLoad(sut)

        mockJoin.stubbedMyStatusResult = .success(MyStatusResponse(status: "waitlisted", waitlistPosition: 7))
        await sut.loadMyStatus()

        XCTAssertEqual(sut.joinState, .waitlisted(position: 7))
    }

    func test_loadMyStatus_error_fallsBackToIdle() async throws {
        mockFetcher.stubbedResult = .success(.fixture(id: "evt1"))
        let sut = makeSUT()
        try await waitForLoad(sut)
        sut.joinState = .pending

        mockJoin.stubbedMyStatusResult = .failure(URLError(.timedOut))
        await sut.loadMyStatus()

        XCTAssertEqual(sut.joinState, .idle)
    }

    // MARK: - joinEvent

    func test_joinEvent_confirmed_setsStateAndToast() async throws {
        mockFetcher.stubbedResult = .success(.fixture(id: "evt1"))
        let sut = makeSUT()
        try await waitForLoad(sut)

        mockJoin.stubbedJoinResult = .success(JoinEventResponse(status: "confirmed", message: "ok"))
        await sut.joinEvent()

        XCTAssertEqual(sut.joinState, .confirmed)
        XCTAssertFalse(sut.isJoiningLoading)
    }

    func test_joinEvent_pending_setsPendingState() async throws {
        mockFetcher.stubbedResult = .success(.fixture(id: "evt1"))
        let sut = makeSUT()
        try await waitForLoad(sut)

        mockJoin.stubbedJoinResult = .success(JoinEventResponse(status: "pending", message: "ok"))
        await sut.joinEvent()

        XCTAssertEqual(sut.joinState, .pending)
    }

    func test_joinEvent_fullError_setsFullState() async throws {
        mockFetcher.stubbedResult = .success(.fixture(id: "evt1"))
        let sut = makeSUT()
        try await waitForLoad(sut)

        mockJoin.stubbedJoinResult = .failure(NSError(
            domain: "test", code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Event is full"]
        ))
        await sut.joinEvent()

        XCTAssertEqual(sut.joinState, .full)
        XCTAssertFalse(sut.isJoiningLoading)
    }

    // MARK: - withdraw / leave

    func test_withdraw_setsWithdrawnState() async throws {
        mockFetcher.stubbedResult = .success(.fixture(id: "evt1"))
        let sut = makeSUT()
        try await waitForLoad(sut)
        sut.joinState = .pending

        await sut.withdraw()

        XCTAssertEqual(sut.joinState, .withdrawn)
    }

    func test_leave_setsWithdrawnState() async throws {
        mockFetcher.stubbedResult = .success(.fixture(id: "evt1"))
        let sut = makeSUT()
        try await waitForLoad(sut)
        sut.joinState = .confirmed

        await sut.leave()

        XCTAssertEqual(sut.joinState, .withdrawn)
    }

    // MARK: - respondToRequest (lato host)

    func test_respondToRequest_accept_updatesQueueLocally() async throws {
        mockFetcher.stubbedResult = .success(.fixture(id: "evt1"))
        let sut = makeSUT()
        try await waitForLoad(sut)
        sut.queueResponse = .fixture(pendingUserIds: ["r1"], confirmedCount: 2)
        // Il reload finale deve restituire lo stato coerente (stesso trucco dei test Home)
        mockJoin.stubbedQueueResult = .success(.fixture(pendingUserIds: [], confirmedCount: 3))

        await sut.respondToRequest(requesterId: "r1", accept: true)

        XCTAssertEqual(sut.queueResponse?.confirmedCount, 3)
        XCTAssertFalse(sut.queueResponse?.pendingUsers.contains { $0.userId == "r1" } ?? true)
        XCTAssertEqual(mockJoin.respondCalls.first?.accept, true)
    }
}
