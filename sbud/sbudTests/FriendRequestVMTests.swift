//
//  FriendRequestVMTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

@MainActor
final class FriendRequestsVMTests: XCTestCase {

    private var mockFriendRepo: MockFriendRepository!
    private var mockUserRepo: MockUserProfileFetching!
    private var mockUserProvider: MockCurrentUserProvider!
    private var sut: FriendRequestsVM!

    override func setUp() {
        super.setUp()
        mockFriendRepo = MockFriendRepository()
        mockUserRepo = MockUserProfileFetching()
        mockUserProvider = MockCurrentUserProvider()
        mockUserProvider.currentUserId = "me"
        let fm = FriendManager(repository: mockFriendRepo, currentUserProvider: mockUserProvider)
        sut = FriendRequestsVM(friendManager: fm, userRepository: mockUserRepo, currentUserProvider: mockUserProvider)
    }

    override func tearDown() {
        sut = nil; mockUserProvider = nil; mockUserRepo = nil; mockFriendRepo = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func test_init_requestsStartEmpty() {
        XCTAssertTrue(sut.requests.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - load()

    func test_load_whenNotAuthenticated_doesNothing() async {
        mockUserProvider.currentUserId = nil
        mockFriendRepo.fetchPendingFriendsRequestsResult = .success(["u1"])
        await sut.load()
        XCTAssertTrue(sut.requests.isEmpty)
        XCTAssertTrue(mockFriendRepo.fetchPendingFriendsRequestsCalls.isEmpty)
    }

    func test_load_resolvesIdsToProfiles() async {
        mockFriendRepo.fetchPendingFriendsRequestsResult = .success(["u1", "u2"])
        var p = UserProfile(id: "u1"); p.name = "Alice"
        mockUserRepo.stubbedResult = .success(p)
        await sut.load()
        XCTAssertEqual(sut.requests.count, 2)
        XCTAssertEqual(mockUserRepo.fetchCallCount, 2)
    }

    func test_load_nilProfileSkipped() async {
        mockFriendRepo.fetchPendingFriendsRequestsResult = .success(["ghost"])
        mockUserRepo.stubbedResult = .success(nil)
        await sut.load()
        XCTAssertTrue(sut.requests.isEmpty)
    }

    func test_load_noPendingRequests_staysEmpty() async {
        mockFriendRepo.fetchPendingFriendsRequestsResult = .success([])
        await sut.load()
        XCTAssertTrue(sut.requests.isEmpty)
    }

    func test_load_onError_setsErrorMessage() async {
        mockFriendRepo.fetchPendingFriendsRequestsResult = .failure(URLError(.notConnectedToInternet))
        await sut.load()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_load_setsIsLoadingFalseAfterCompletion() async {
        await sut.load()
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - accept(_:)

    func test_accept_removesUserFromRequests() async {
        let user = UserProfile(id: "u1")
        sut.requests = [user]
        await sut.accept(user)
        XCTAssertTrue(sut.requests.isEmpty)
        XCTAssertEqual(mockFriendRepo.acceptFriendRequestCalls.first?.requesterId, "u1")
    }

    func test_accept_onlyRemovesAcceptedUser() async {
        let a = UserProfile(id: "a")
        let b = UserProfile(id: "b")
        sut.requests = [a, b]
        await sut.accept(a)
        XCTAssertEqual(sut.requests.map(\.id), ["b"])
    }

    func test_accept_onFailure_keepsUserAndSetsError() async {
        let user = UserProfile(id: "u1")
        sut.requests = [user]
        mockFriendRepo.acceptFriendRequestResult = .failure(URLError(.notConnectedToInternet))
        await sut.accept(user)
        XCTAssertEqual(sut.requests.count, 1)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - decline(_:)

    func test_decline_removesUserFromRequests() async {
        let user = UserProfile(id: "u1")
        sut.requests = [user]
        await sut.decline(user)
        XCTAssertTrue(sut.requests.isEmpty)
        XCTAssertEqual(mockFriendRepo.declineFriendRequestCalls.first?.requesterId, "u1")
    }

    func test_decline_onFailure_keepsUserAndSetsError() async {
        let user = UserProfile(id: "u1")
        sut.requests = [user]
        mockFriendRepo.declineFriendRequestResult = .failure(URLError(.notConnectedToInternet))
        await sut.decline(user)
        XCTAssertEqual(sut.requests.count, 1)
        XCTAssertNotNil(sut.errorMessage)
    }
}
