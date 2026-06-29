//
//  ViewModelMoreInfoEventTests.swift
//  sbudTests
//

import XCTest
@testable import sbud

// MARK: - Mocks

final class MockEventFetcher: EventFetching {
    var callCount = 0
    var stubbedResult: Result<EventFullDetails, Error> = .failure(URLError(.unknown))

    func fetchEvent(eventId: String) async throws -> EventFullDetails {
        callCount += 1
        switch stubbedResult {
        case .success(let d): return d
        case .failure(let e): throw e
        }
    }
}

final class MockJoinRequester: JoinEventRequesting {
    var joinCallCount = 0
    var withdrawCallCount = 0
    var leaveCallCount = 0
    var statusCallCount = 0

    var stubbedJoinResult: Result<JoinEventResponse, Error> =
        .success(JoinEventResponse(status: "pending", message: "ok"))
    var stubbedWithdrawResult: Result<WithdrawResponse, Error> =
        .success(WithdrawResponse(status: "withdrawn", message: "ok"))
    var stubbedLeaveResult: Result<LeaveResponse, Error> =
        .success(LeaveResponse(status: "left", message: "ok"))
    var stubbedStatusResult: Result<MyStatusResponse, Error> =
        .success(MyStatusResponse(status: "idle", waitlistPosition: nil))

    func joinEvent(eventId: String) async throws -> JoinEventResponse {
        joinCallCount += 1
        switch stubbedJoinResult {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }

    func withdraw(eventId: String) async throws -> WithdrawResponse {
        withdrawCallCount += 1
        switch stubbedWithdrawResult {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }

    func leave(eventId: String) async throws -> LeaveResponse {
        leaveCallCount += 1
        switch stubbedLeaveResult {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }

    func getMyStatus(eventId: String) async throws -> MyStatusResponse {
        statusCallCount += 1
        switch stubbedStatusResult {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }

    func getPendingQueue(eventId: String) async throws -> JoinQueueResponse {
        JoinQueueResponse(
            confirmedCount: 0, pendingCount: 0, waitlistCount: 0,
            capacity: nil, isCapacityFull: false, waitlistMax: 0, pendingUsers: []
        )
    }

    func respondToRequest(eventId: String, requesterId: String, accept: Bool) async throws -> JoinRespondResponse {
        JoinRespondResponse(status: "ok", message: "ok")
    }
}

final class MockCurrentUserProvider: CurrentUserProviding {
    var currentUserId: String?
}

// MARK: - EventFullDetails fixture

private func makeEventDetails(creatorId: String = "creator-1") -> EventFullDetails {
    EventFullDetails(
        id: "event-1",
        title: "Morning Run",
        creator: CreatorInfo(id: creatorId, name: "Alice", surName: "Smith"),
        activityDetails: ExtraArgsHolder(),
        isDateConfirmed: false,
        isLocationConfirmed: false,
        isPublic: true,
        joinCondition: .requestFromHost,
        createdAt: Date(),
        dateLocations: [],
        numSessions: 0
    )
}

// MARK: - Tests

final class ViewModelMoreInfoEventTests: XCTestCase {

    private var mockFetcher: MockEventFetcher!
    private var mockJoin: MockJoinRequester!
    private var mockUser: MockCurrentUserProvider!

    override func setUp() {
        super.setUp()
        mockFetcher = MockEventFetcher()
        mockJoin    = MockJoinRequester()
        mockUser    = MockCurrentUserProvider()
    }

    override func tearDown() {
        mockFetcher = nil
        mockJoin    = nil
        mockUser    = nil
        super.tearDown()
    }

    private func makeSUT(userId: String? = nil) -> ViewModelMoreInfoEvent {
        mockUser.currentUserId = userId
        return ViewModelMoreInfoEvent(
            eventId: "event-1",
            joinRequester: mockJoin,
            eventFetcher: mockFetcher,
            currentUserProvider: mockUser
        )
    }

    // MARK: - loadDetails — success

    func test_loadDetails_success_setsFullDetails() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertNotNil(sut.fullDetails)
    }

    func test_loadDetails_success_isLoadingFalse() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadDetails_success_isErrorLoadingFalse() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.isErrorLoading)
    }

    // MARK: - loadDetails — failure

    func test_loadDetails_failure_isErrorLoadingTrue() async throws {
        mockFetcher.stubbedResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(sut.isErrorLoading)
    }

    func test_loadDetails_failure_isLoadingFalse() async throws {
        mockFetcher.stubbedResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadDetails_failure_fullDetailsNil() async throws {
        mockFetcher.stubbedResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertNil(sut.fullDetails)
    }

    // MARK: - Host detection

    func test_loadDetails_currentUserIsCreator_setsIsCurrentUserHost() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails(creatorId: "user-42"))
        let sut = makeSUT(userId: "user-42")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(sut.isCurrentUserHost)
    }

    func test_loadDetails_currentUserIsNotCreator_isCurrentUserHostFalse() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails(creatorId: "creator-1"))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.isCurrentUserHost)
    }

    func test_loadDetails_nilUserId_isCurrentUserHostFalse() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails(creatorId: "creator-1"))
        let sut = makeSUT(userId: nil)
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.isCurrentUserHost)
    }

    // Host doesn't fetch status — non-host does
    func test_loadDetails_nonHost_fetchesMyStatus() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails(creatorId: "creator-1"))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(mockJoin.statusCallCount, 1)
    }

    func test_loadDetails_isHost_doesNotFetchMyStatus() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails(creatorId: "host-99"))
        let sut = makeSUT(userId: "host-99")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(mockJoin.statusCallCount, 0)
    }

    // MARK: - loadMyStatus — all string mappings

    func test_loadMyStatus_pending_setsJoinStatePending() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        mockJoin.stubbedStatusResult = .success(MyStatusResponse(status: "pending", waitlistPosition: nil))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.joinState, .pending)
    }

    func test_loadMyStatus_confirmed_setsJoinStateConfirmed() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        mockJoin.stubbedStatusResult = .success(MyStatusResponse(status: "confirmed", waitlistPosition: nil))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.joinState, .confirmed)
    }

    func test_loadMyStatus_rejected_setsJoinStateRejected() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        mockJoin.stubbedStatusResult = .success(MyStatusResponse(status: "rejected", waitlistPosition: nil))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.joinState, .rejected)
    }

    func test_loadMyStatus_withdrawn_setsJoinStateWithdrawn() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        mockJoin.stubbedStatusResult = .success(MyStatusResponse(status: "withdrawn", waitlistPosition: nil))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.joinState, .withdrawn)
    }

    func test_loadMyStatus_left_setsJoinStateLeft() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        mockJoin.stubbedStatusResult = .success(MyStatusResponse(status: "left", waitlistPosition: nil))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.joinState, .withdrawn)
    }

    func test_loadMyStatus_waitlisted_setsJoinStateWithPosition() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        mockJoin.stubbedStatusResult = .success(MyStatusResponse(status: "waitlisted", waitlistPosition: 4))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.joinState, .waitlisted(position: 4))
    }

    func test_loadMyStatus_unknown_setsJoinStateIdle() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        mockJoin.stubbedStatusResult = .success(MyStatusResponse(status: "unknown_status", waitlistPosition: nil))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.joinState, .idle)
    }

    func test_loadMyStatus_error_fallsBackToIdle() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        mockJoin.stubbedStatusResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.joinState, .idle)
    }

    // MARK: - joinEvent

    func test_joinEvent_pending_setsJoinStatePending() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        mockJoin.stubbedJoinResult = .success(JoinEventResponse(status: "pending", message: "ok"))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        await sut.joinEvent()
        XCTAssertEqual(sut.joinState, .pending)
    }

    func test_joinEvent_waitlisted_setsJoinStateWaitlisted() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        mockJoin.stubbedJoinResult = .success(JoinEventResponse(status: "waitlisted", message: "You're on the list"))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        await sut.joinEvent()
        XCTAssertEqual(sut.joinState, .waitlisted(position: 0))
    }

    func test_joinEvent_fullError_setsJoinStateFull() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        mockJoin.stubbedJoinResult = .failure(NSError(
            domain: "test", code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Event is full"]
        ))
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        await sut.joinEvent()
        XCTAssertEqual(sut.joinState, .full)
    }

    func test_joinEvent_isJoiningLoadingFalseAfter() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        await sut.joinEvent()
        XCTAssertFalse(sut.isJoiningLoading)
    }

    // MARK: - withdraw

    func test_withdraw_success_setsJoinStateWithdrawn() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        await sut.withdraw()
        XCTAssertEqual(sut.joinState, .withdrawn)
    }

    func test_withdraw_callsWithdrawOnce() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        await sut.withdraw()
        XCTAssertEqual(mockJoin.withdrawCallCount, 1)
    }

    // MARK: - leave

    func test_leave_success_setsJoinStateLeft() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        await sut.leave()
        XCTAssertEqual(sut.joinState, .withdrawn)
    }

    func test_leave_callsLeaveOnce() async throws {
        mockFetcher.stubbedResult = .success(makeEventDetails())
        let sut = makeSUT(userId: "other-user")
        try await Task.sleep(nanoseconds: 200_000_000)
        await sut.leave()
        XCTAssertEqual(mockJoin.leaveCallCount, 1)
    }
}
