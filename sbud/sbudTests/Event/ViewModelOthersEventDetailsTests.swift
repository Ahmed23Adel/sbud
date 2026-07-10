//
//  ViewModelOthersEventDetailsTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 10/07/2026.
//


import XCTest
import FirebaseFirestore
@testable import sbud

@MainActor
final class ViewModelOthersEventDetailsTests: XCTestCase {

    private var mockJoin: MockJoinRequester!

    override func setUp() {
        super.setUp()
        mockJoin = MockJoinRequester()
        PopUpGenerator.shared.clearAll()
    }

    override func tearDown() {
        PopUpGenerator.shared.clearAll()
        mockJoin = nil
        super.tearDown()
    }

    private func makeSUT(eventId: String = "others_evt_1") -> ViewModelOthersEventDetails {
        ViewModelOthersEventDetails(eventId: eventId, joinRequester: mockJoin)
    }

    // MARK: - Init

    func test_init_setsEventId() {
        let sut = makeSUT(eventId: "abc")
        XCTAssertEqual(sut.eventId, "abc")
    }

    func test_init_initialState() {
        let sut = makeSUT()
        XCTAssertNil(sut.myEventDertails)
        XCTAssertEqual(sut.joinState, .idle)
        XCTAssertFalse(sut.isShowJoinSessionButton)
    }

    // MARK: - loadMyStatus (mapping)

    func test_loadMyStatus_mapsAllServerStates() async {
        let sut = makeSUT()
        let cases: [(String, JoinState)] = [
            ("pending", .pending), ("confirmed", .confirmed),
            ("rejected", .rejected), ("withdrawn", .withdrawn),
            ("left", .withdrawn), ("boh", .idle)
        ]
        for (server, expected) in cases {
            mockJoin.stubbedMyStatusResult = .success(MyStatusResponse(status: server, waitlistPosition: nil))
            await sut.loadMyStatus()
            XCTAssertEqual(sut.joinState, expected, "server status '\(server)'")
        }
    }

    func test_loadMyStatus_waitlisted_withPosition() async {
        let sut = makeSUT()
        mockJoin.stubbedMyStatusResult = .success(MyStatusResponse(status: "waitlisted", waitlistPosition: 4))
        await sut.loadMyStatus()
        XCTAssertEqual(sut.joinState, .waitlisted(position: 4))
    }

    func test_loadMyStatus_error_setsIdle() async {
        let sut = makeSUT()
        sut.joinState = .confirmed
        mockJoin.stubbedMyStatusResult = .failure(URLError(.timedOut))
        await sut.loadMyStatus()
        XCTAssertEqual(sut.joinState, .idle)
    }

    // MARK: - joinEvent

    func test_joinEvent_confirmed() async {
        let sut = makeSUT()
        mockJoin.stubbedJoinResult = .success(JoinEventResponse(status: "confirmed", message: "ok"))
        await sut.joinEvent()
        XCTAssertEqual(sut.joinState, .confirmed)
        XCTAssertFalse(sut.isJoiningLoading)
    }

    func test_joinEvent_pending() async {
        let sut = makeSUT()
        mockJoin.stubbedJoinResult = .success(JoinEventResponse(status: "pending", message: "ok"))
        await sut.joinEvent()
        XCTAssertEqual(sut.joinState, .pending)
    }

    func test_joinEvent_fullError_setsFull() async {
        let sut = makeSUT()
        mockJoin.stubbedJoinResult = .failure(NSError(
            domain: "t", code: 1, userInfo: [NSLocalizedDescriptionKey: "Event is full"]
        ))
        await sut.joinEvent()
        XCTAssertEqual(sut.joinState, .full)
    }

    // MARK: - withdraw / leave

    func test_withdraw_setsWithdrawn() async {
        let sut = makeSUT()
        sut.joinState = .pending
        await sut.withdraw()
        XCTAssertEqual(sut.joinState, .withdrawn)
    }

    func test_leave_success_returnsTrue() async {
        let sut = makeSUT()
        let ok = await sut.leave()
        XCTAssertTrue(ok)
    }

    func test_leave_failure_returnsFalse() async {
        let sut = makeSUT()
        mockJoin.stubbedLeaveResult = .failure(URLError(.notConnectedToInternet))
        let ok = await sut.leave()
        XCTAssertFalse(ok)
    }

    // MARK: - respondToRequest

    func test_respondToRequest_accept_updatesQueue() async {
        let sut = makeSUT()
        sut.queueResponse = .fixture(pendingUserIds: ["r1"], confirmedCount: 1)
        mockJoin.stubbedQueueResult = .success(.fixture(pendingUserIds: [], confirmedCount: 2))

        await sut.respondToRequest(requesterId: "r1", accept: true)

        XCTAssertEqual(sut.queueResponse?.confirmedCount, 2)
        XCTAssertEqual(mockJoin.respondCalls.count, 1)
    }

    func test_respondToRequest_reject_decrementsPending() async {
        let sut = makeSUT()
        sut.queueResponse = .fixture(pendingUserIds: ["r1"], confirmedCount: 1)
        mockJoin.stubbedQueueResult = .success(.fixture(pendingUserIds: [], confirmedCount: 1))

        await sut.respondToRequest(requesterId: "r1", accept: false)

        XCTAssertEqual(mockJoin.respondCalls.first?.accept, false)
    }

    // MARK: - checkSession (Firestore emulato via refresh)

    func test_refresh_sessionExists_showsJoinSessionButton() async throws {
        // Semina una sessione in corso per questo evento sull'emulatore
        let repo = OnGoingSessionRepository()
        try await repo.create(OnGoingSession(
            eventId: "others_evt_1",
            startDateTime: Date(),
            creatorId: "someone",
            activityType: .running
        ))
        let sut = makeSUT()

        await sut.refresh()

        XCTAssertTrue(sut.isShowJoinSessionButton)
    }
}