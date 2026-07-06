//
//  OwnProfileVMTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

@MainActor
final class OwnProfileVMTests: XCTestCase {

    private var mockUserRepo: MockUserProfileFetching!
    private var mockFriendRepo: MockFriendRepository!
    private var mockUserProvider: MockCurrentUserProvider!
    private var sut: OwnProfileVM!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserProfileFetching()
        mockFriendRepo = MockFriendRepository()
        mockUserProvider = MockCurrentUserProvider()
        mockUserProvider.currentUserId = "me"
        let friendManager = FriendManager(repository: mockFriendRepo, currentUserProvider: mockUserProvider)
        sut = OwnProfileVM(userId: "me", userRepository: mockUserRepo,
                           friendManager: friendManager, currentUserProvider: mockUserProvider)
    }

    override func tearDown() {
        sut = nil; mockUserProvider = nil; mockFriendRepo = nil; mockUserRepo = nil
        super.tearDown()
    }

    func test_init_pendingCountsStartAtZero() {
        XCTAssertEqual(sut.pendingFriendsRequestCount, 0)
        XCTAssertEqual(sut.pendingHostsRequestCount, 0)
    }

    func test_load_populatesPendingFriendsCount() async {
        mockFriendRepo.fetchPendingFriendsRequestsResult = .success(["a", "b", "c"])
        await sut.load()
        XCTAssertEqual(sut.pendingFriendsRequestCount, 3)
    }

    func test_load_populatesPendingHostsCount() async {
        mockFriendRepo.fetchPendingHostsRequestsResult = .success(["evt1", "evt2"])
        await sut.load()
        XCTAssertEqual(sut.pendingHostsRequestCount, 2)
    }

    func test_load_whenNotAuthenticated_countsStayZero() async {
        mockUserProvider.currentUserId = nil
        mockFriendRepo.fetchPendingFriendsRequestsResult = .success(["x"])
        await sut.load()
        XCTAssertEqual(sut.pendingFriendsRequestCount, 0)
        XCTAssertTrue(mockFriendRepo.fetchPendingFriendsRequestsCalls.isEmpty)
    }

    func test_load_passesCurrentUserId_toFriendManager() async {
        mockFriendRepo.fetchPendingFriendsRequestsResult = .success([])
        mockFriendRepo.fetchPendingHostsRequestsResult = .success([])
        await sut.load()
        XCTAssertEqual(mockFriendRepo.fetchPendingFriendsRequestsCalls, ["me"])
        XCTAssertEqual(mockFriendRepo.fetchPendingHostsRequestsCalls, ["me"])
    }

    func test_load_friendsRequestFetchFails_countsDefaultToZero() async {
        mockFriendRepo.fetchPendingFriendsRequestsResult = .failure(URLError(.notConnectedToInternet))
        await sut.load()
        XCTAssertEqual(sut.pendingFriendsRequestCount, 0)
    }

    func test_load_fetchesProfileForCorrectUserId() async {
        await sut.load()
        XCTAssertEqual(mockUserRepo.lastRequestedId, "me")
    }
}
