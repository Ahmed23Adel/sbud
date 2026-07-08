//
//  FriendManagerTests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//


import XCTest
@testable import sbud

// MARK: - MockFriendRepository

final class MockFriendRepository: IFriendRepository {

    // Call tracking
    private(set) var addFriendDirectlyCalls: [(from: String, to: String)] = []
    private(set) var sendFriendRequestCalls: [(from: String, to: String)] = []
    private(set) var cancelFriendRequestCalls: [(from: String, to: String)] = []
    private(set) var acceptFriendRequestCalls: [(currentUserId: String, requesterId: String)] = []
    private(set) var declineFriendRequestCalls: [(currentUserId: String, requesterId: String)] = []
    private(set) var removeFriendCalls: [(currentUserId: String, targetUserId: String)] = []
    private(set) var isFriendCalls: [(currentUserId: String, targetUserId: String)] = []
    private(set) var hasSentRequestCalls: [(from: String, to: String)] = []
    private(set) var hasReceivedRequestCalls: [(currentUserId: String, from: String)] = []
    private(set) var getFriendStatusCalls: [(currentUserId: String, targetUserId: String)] = []
    private(set) var fetchFriendsCalls: [String] = []
    private(set) var fetchPendingFriendsRequestsCalls: [String] = []
    private(set) var fetchPendingHostsRequestsCalls: [String] = []

    // Stubbed results
    var addFriendDirectlyResult: Result<Void, Error> = .success(())
    var sendFriendRequestResult: Result<Void, Error> = .success(())
    var cancelFriendRequestResult: Result<Void, Error> = .success(())
    var acceptFriendRequestResult: Result<Void, Error> = .success(())
    var declineFriendRequestResult: Result<Void, Error> = .success(())
    var removeFriendResult: Result<Void, Error> = .success(())
    var isFriendResult: Result<Bool, Error> = .success(false)
    var hasSentRequestResult: Result<Bool, Error> = .success(false)
    var hasReceivedRequestResult: Result<Bool, Error> = .success(false)
    var getFriendStatusResult: Result<FriendStatus, Error> = .success(.notFriend)
    var fetchFriendsResult: Result<[String], Error> = .success([])
    var fetchPendingFriendsRequestsResult: Result<[String], Error> = .success([])
    var fetchPendingHostsRequestsResult: Result<[String], Error> = .success([])

    func addFriendDirectly(fromUserId: String, toUserId: String) async throws {
        addFriendDirectlyCalls.append((fromUserId, toUserId))
        if case .failure(let e) = addFriendDirectlyResult { throw e }
    }

    func sendFriendRequest(fromUserId: String, toUserId: String) async throws {
        sendFriendRequestCalls.append((fromUserId, toUserId))
        if case .failure(let e) = sendFriendRequestResult { throw e }
    }

    func cancelFriendRequest(fromUserId: String, toUserId: String) async throws {
        cancelFriendRequestCalls.append((fromUserId, toUserId))
        if case .failure(let e) = cancelFriendRequestResult { throw e }
    }

    func acceptFriendRequest(currentUserId: String, requesterId: String) async throws {
        acceptFriendRequestCalls.append((currentUserId, requesterId))
        if case .failure(let e) = acceptFriendRequestResult { throw e }
    }

    func declineFriendRequest(currentUserId: String, requesterId: String) async throws {
        declineFriendRequestCalls.append((currentUserId, requesterId))
        if case .failure(let e) = declineFriendRequestResult { throw e }
    }

    func removeFriend(currentUserId: String, targetUserId: String) async throws {
        removeFriendCalls.append((currentUserId, targetUserId))
        if case .failure(let e) = removeFriendResult { throw e }
    }

    func isFriend(currentUserId: String, targetUserId: String) async throws -> Bool {
        isFriendCalls.append((currentUserId, targetUserId))
        switch isFriendResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }

    func hasSentRequest(fromUserId: String, toUserId: String) async throws -> Bool {
        hasSentRequestCalls.append((fromUserId, toUserId))
        switch hasSentRequestResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }

    func hasReceivedRequest(currentUserId: String, fromUserId: String) async throws -> Bool {
        hasReceivedRequestCalls.append((currentUserId, fromUserId))
        switch hasReceivedRequestResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }

    func getFriendStatus(currentUserId: String, targetUserId: String) async throws -> FriendStatus {
        getFriendStatusCalls.append((currentUserId, targetUserId))
        switch getFriendStatusResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }

    func fetchFriends(userId: String) async throws -> [String] {
        fetchFriendsCalls.append(userId)
        switch fetchFriendsResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }

    func fetchPendingFriendsRequests(userId: String) async throws -> [String] {
        fetchPendingFriendsRequestsCalls.append(userId)
        switch fetchPendingFriendsRequestsResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }

    func fetchPendingHostsRequests(userId: String) async throws -> [String] {
        fetchPendingHostsRequestsCalls.append(userId)
        switch fetchPendingHostsRequestsResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }
}

// MARK: - FriendManagerTests

final class FriendManagerTests: XCTestCase {

    private var mockRepository: MockFriendRepository!
    private var mockUserProvider: MockCurrentUserProvider!
    private var sut: FriendManager!

    override func setUp() {
        super.setUp()
        mockRepository = MockFriendRepository()
        mockUserProvider = MockCurrentUserProvider()
        mockUserProvider.currentUserId = "currentUser"
        sut = FriendManager(repository: mockRepository, currentUserProvider: mockUserProvider)
    }

    override func tearDown() {
        sut = nil
        mockUserProvider = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Not Authenticated Guard

    func test_addFriend_whenNotAuthenticated_throwsNotAuthenticated() async {
        mockUserProvider.currentUserId = nil
        await assertThrowsNotAuthenticated {
            try await self.sut.addFriend(targetUserId: "u2", isTargetPrivate: false)
        }
        XCTAssertTrue(mockRepository.addFriendDirectlyCalls.isEmpty)
    }

    func test_cancelRequest_whenNotAuthenticated_throwsNotAuthenticated() async {
        mockUserProvider.currentUserId = nil
        await assertThrowsNotAuthenticated {
            try await self.sut.cancelRequest(targetUserId: "u2")
        }
    }

    func test_acceptRequest_whenNotAuthenticated_throwsNotAuthenticated() async {
        mockUserProvider.currentUserId = nil
        await assertThrowsNotAuthenticated {
            try await self.sut.acceptRequest(requesterId: "u2")
        }
    }

    func test_declineRequest_whenNotAuthenticated_throwsNotAuthenticated() async {
        mockUserProvider.currentUserId = nil
        await assertThrowsNotAuthenticated {
            try await self.sut.declineRequest(requesterId: "u2")
        }
    }

    func test_removeFriend_whenNotAuthenticated_throwsNotAuthenticated() async {
        mockUserProvider.currentUserId = nil
        await assertThrowsNotAuthenticated {
            try await self.sut.removeFriend(targetUserId: "u2")
        }
    }

    func test_getFriendStatus_whenNotAuthenticated_returnsNotFriendWithoutThrowing() async throws {
        mockUserProvider.currentUserId = nil
        let status = try await sut.getFriendStatus(targetUserId: "u2")
        XCTAssertEqual(status, .notFriend)
        XCTAssertTrue(mockRepository.getFriendStatusCalls.isEmpty, "Should short-circuit before reaching the repository")
    }

    func test_isFriend_whenNotAuthenticated_returnsFalseWithoutThrowing() async throws {
        mockUserProvider.currentUserId = nil
        let result = try await sut.isFriend(targetUserId: "u2")
        XCTAssertFalse(result)
        XCTAssertTrue(mockRepository.isFriendCalls.isEmpty)
    }

    // MARK: - Cannot Add Self

    func test_addFriend_targetingSelf_throwsCannotAddSelf() async {
        mockUserProvider.currentUserId = "u1"
        do {
            try await sut.addFriend(targetUserId: "u1", isTargetPrivate: false)
            XCTFail("Expected FriendError.cannotAddSelf")
        } catch let error as FriendError {
            XCTAssertEqual(error.errorDescription, FriendError.cannotAddSelf.errorDescription)
        } catch {
            XCTFail("Expected FriendError, got \(error)")
        }
        XCTAssertTrue(mockRepository.addFriendDirectlyCalls.isEmpty)
        XCTAssertTrue(mockRepository.sendFriendRequestCalls.isEmpty)
    }

    // MARK: - addFriend Routing (private vs. open accounts)

    func test_addFriend_targetIsPrivate_sendsFriendRequest() async throws {
        try await sut.addFriend(targetUserId: "u2", isTargetPrivate: true)

        XCTAssertEqual(mockRepository.sendFriendRequestCalls.count, 1)
        XCTAssertEqual(mockRepository.sendFriendRequestCalls.first?.from, "currentUser")
        XCTAssertEqual(mockRepository.sendFriendRequestCalls.first?.to, "u2")
        XCTAssertTrue(mockRepository.addFriendDirectlyCalls.isEmpty)
    }

    func test_addFriend_targetIsOpen_addsDirectly() async throws {
        try await sut.addFriend(targetUserId: "u2", isTargetPrivate: false)

        XCTAssertEqual(mockRepository.addFriendDirectlyCalls.count, 1)
        XCTAssertEqual(mockRepository.addFriendDirectlyCalls.first?.from, "currentUser")
        XCTAssertEqual(mockRepository.addFriendDirectlyCalls.first?.to, "u2")
        XCTAssertTrue(mockRepository.sendFriendRequestCalls.isEmpty)
    }

    func test_addFriend_propagatesRepositoryError() async {
        mockRepository.addFriendDirectlyResult = .failure(URLError(.notConnectedToInternet))
        do {
            try await sut.addFriend(targetUserId: "u2", isTargetPrivate: false)
            XCTFail("Expected repository error to propagate")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
        }
    }

    // MARK: - cancelRequest / acceptRequest / declineRequest / removeFriend

    func test_cancelRequest_callsRepositoryWithCurrentUserAsFrom() async throws {
        try await sut.cancelRequest(targetUserId: "u2")
        XCTAssertEqual(mockRepository.cancelFriendRequestCalls.first?.from, "currentUser")
        XCTAssertEqual(mockRepository.cancelFriendRequestCalls.first?.to, "u2")
    }

    func test_acceptRequest_callsRepositoryWithCurrentUserAndRequester() async throws {
        try await sut.acceptRequest(requesterId: "requester1")
        XCTAssertEqual(mockRepository.acceptFriendRequestCalls.first?.currentUserId, "currentUser")
        XCTAssertEqual(mockRepository.acceptFriendRequestCalls.first?.requesterId, "requester1")
    }

    func test_declineRequest_callsRepositoryWithCurrentUserAndRequester() async throws {
        try await sut.declineRequest(requesterId: "requester1")
        XCTAssertEqual(mockRepository.declineFriendRequestCalls.first?.currentUserId, "currentUser")
        XCTAssertEqual(mockRepository.declineFriendRequestCalls.first?.requesterId, "requester1")
    }

    func test_removeFriend_callsRepositoryWithCurrentUserAndTarget() async throws {
        try await sut.removeFriend(targetUserId: "u2")
        XCTAssertEqual(mockRepository.removeFriendCalls.first?.currentUserId, "currentUser")
        XCTAssertEqual(mockRepository.removeFriendCalls.first?.targetUserId, "u2")
    }

    // MARK: - getFriendStatus / isFriend

    func test_getFriendStatus_returnsRepositoryValue() async throws {
        mockRepository.getFriendStatusResult = .success(.friends)
        let status = try await sut.getFriendStatus(targetUserId: "u2")
        XCTAssertEqual(status, .friends)
    }

    func test_isFriend_returnsRepositoryValue() async throws {
        mockRepository.isFriendResult = .success(true)
        let result = try await sut.isFriend(targetUserId: "u2")
        XCTAssertTrue(result)
    }

    // MARK: - Fetch Lists (no auth guard — operate on an arbitrary userId)

    func test_fetchFriends_delegatesToRepository() async throws {
        mockRepository.fetchFriendsResult = .success(["f1", "f2"])
        let result = try await sut.fetchFriends(userId: "u9")
        XCTAssertEqual(result, ["f1", "f2"])
        XCTAssertEqual(mockRepository.fetchFriendsCalls, ["u9"])
    }

    func test_fetchFriendsPendingRequests_delegatesToRepository() async throws {
        mockRepository.fetchPendingFriendsRequestsResult = .success(["r1"])
        let result = try await sut.fetchFriendsPendingRequests(userId: "u9")
        XCTAssertEqual(result, ["r1"])
        XCTAssertEqual(mockRepository.fetchPendingFriendsRequestsCalls, ["u9"])
    }

    func test_fetchHostsPendingRequests_delegatesToRepository() async throws {
        mockRepository.fetchPendingHostsRequestsResult = .success(["evt1"])
        let result = try await sut.fetchHostsPendingRequests(userId: "u9")
        XCTAssertEqual(result, ["evt1"])
        XCTAssertEqual(mockRepository.fetchPendingHostsRequestsCalls, ["u9"])
    }

    func test_fetchFriends_doesNotRequireAuthentication() async throws {
        mockUserProvider.currentUserId = nil
        mockRepository.fetchFriendsResult = .success(["f1"])
        let result = try await sut.fetchFriends(userId: "someoneElse")
        XCTAssertEqual(result, ["f1"], "Friend list lookups are not gated by the current user's auth state")
    }

    // MARK: - FriendStatus / FriendError models

    func test_friendStatus_casesAreDistinct() {
        XCTAssertNotEqual(FriendStatus.notFriend, .friends)
        XCTAssertNotEqual(FriendStatus.requestSent, .requestReceived)
    }

    func test_friendError_notAuthenticated_hasDescription() {
        XCTAssertEqual(FriendError.notAuthenticated.errorDescription, "User not authenticated.")
    }

    func test_friendError_cannotAddSelf_hasDescription() {
        XCTAssertEqual(FriendError.cannotAddSelf.errorDescription, "You cannot add yourself as a friend.")
    }

    // MARK: - Helpers

    private func assertThrowsNotAuthenticated(
        _ operation: @escaping () async throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            try await operation()
            XCTFail("Expected FriendError.notAuthenticated", file: file, line: line)
        } catch let error as FriendError {
            XCTAssertEqual(
                error.errorDescription, FriendError.notAuthenticated.errorDescription,
                file: file, line: line
            )
        } catch {
            XCTFail("Expected FriendError, got \(error)", file: file, line: line)
        }
    }
}
