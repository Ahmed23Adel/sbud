//
//  FriendListVMTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

@MainActor
final class FriendListVMTests: XCTestCase {

    private var mockFriendRepo: MockFriendRepository!
    private var mockUserRepo: MockUserProfileFetching!
    private var sut: FriendListVM!

    override func setUp() {
        super.setUp()
        mockFriendRepo = MockFriendRepository()
        mockUserRepo = MockUserProfileFetching()
        let provider = MockCurrentUserProvider()
        provider.currentUserId = "viewer"
        let fm = FriendManager(repository: mockFriendRepo, currentUserProvider: provider)
        sut = FriendListVM(userId: "target", friendManager: fm, userRepository: mockUserRepo)
    }

    override func tearDown() {
        sut = nil; mockUserRepo = nil; mockFriendRepo = nil
        super.tearDown()
    }

    func test_init_usersStartEmpty() {
        XCTAssertTrue(sut.users.isEmpty)
    }

    func test_load_resolvesIdsToProfiles() async {
        mockFriendRepo.fetchFriendsResult = .success(["f1", "f2"])
        var p = UserProfile(id: "f1"); p.name = "Alice"
        mockUserRepo.stubbedResult = .success(p)
        await sut.load()
        XCTAssertEqual(sut.users.count, 2)
        XCTAssertEqual(mockUserRepo.fetchCallCount, 2)
    }

    func test_load_nilProfileSkipped() async {
        mockFriendRepo.fetchFriendsResult = .success(["ghost"])
        mockUserRepo.stubbedResult = .success(nil)
        await sut.load()
        XCTAssertTrue(sut.users.isEmpty)
    }

    func test_load_noFriends_staysEmpty() async {
        mockFriendRepo.fetchFriendsResult = .success([])
        await sut.load()
        XCTAssertTrue(sut.users.isEmpty)
    }

    func test_load_onError_setsErrorMessage() async {
        mockFriendRepo.fetchFriendsResult = .failure(URLError(.notConnectedToInternet))
        await sut.load()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_load_setsIsLoadingFalseAfterCompletion() async {
        await sut.load()
        XCTAssertFalse(sut.isLoading)
    }
}
