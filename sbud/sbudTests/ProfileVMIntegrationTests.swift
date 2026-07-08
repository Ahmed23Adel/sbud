//
//  ProfileVMIntegrationTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

// MARK: - FakeUserDirectory

final class FakeUserDirectory: UserProfileFetching {
    private var profiles: [String: UserProfile] = [:]
    func register(_ p: UserProfile) { profiles[p.id] = p }
    func fetchProfile(_ id: String) async throws -> UserProfile? { profiles[id] }
}

// MARK: - ProfileVMIntegrationTests

@MainActor
final class ProfileVMIntegrationTests: XCTestCase {

    private var repository: FakeFriendRepository!
    private var directory: FakeUserDirectory!

    override func setUp() {
        super.setUp()
        repository = FakeFriendRepository()
        directory  = FakeUserDirectory()
    }

    override func tearDown() {
        directory = nil; repository = nil
        super.tearDown()
    }

    private func makeProvider(_ id: String) -> MockCurrentUserProvider {
        let p = MockCurrentUserProvider(); p.currentUserId = id; return p
    }

    // MARK: - 1. Request → Accept → badge clears + friendship created

    func test_requestThenAccept_clearsBadgeAndCreatesFriendship() async throws {
        var bob = UserProfile(id: "bob"); bob.name = "Bob"
        directory.register(bob)

        let meProvider  = makeProvider("me")
        let bobProvider = makeProvider("bob")
        let meManager   = FriendManager(repository: repository, currentUserProvider: meProvider)
        let bobManager  = FriendManager(repository: repository, currentUserProvider: bobProvider)

        try await bobManager.addFriend(targetUserId: "me", isTargetPrivate: true)

        let ownVM = OwnProfileVM(userId: "me", userRepository: directory,
                                  friendManager: meManager, currentUserProvider: meProvider)
        await ownVM.load()
        XCTAssertEqual(ownVM.pendingFriendsRequestCount, 1)

        let requestsVM = FriendRequestsVM(friendManager: meManager, userRepository: directory,
                                          currentUserProvider: meProvider)
        await requestsVM.load()
        XCTAssertEqual(requestsVM.requests.map(\.id), ["bob"])

        await requestsVM.accept(bob)
        XCTAssertTrue(requestsVM.requests.isEmpty)

        await ownVM.load()
        XCTAssertEqual(ownVM.pendingFriendsRequestCount, 0)

        let nowFriends = try await meManager.isFriend(targetUserId: "bob")
        XCTAssertTrue(nowFriends)
    }

    // MARK: - 2. Decline → no friendship created

    func test_requestThenDecline_clearsBadgeWithoutFriendship() async throws {
        var carol = UserProfile(id: "carol"); carol.name = "Carol"
        directory.register(carol)

        let meProvider    = makeProvider("me")
        let carolProvider = makeProvider("carol")
        let meManager     = FriendManager(repository: repository, currentUserProvider: meProvider)
        let carolManager  = FriendManager(repository: repository, currentUserProvider: carolProvider)

        try await carolManager.addFriend(targetUserId: "me", isTargetPrivate: true)

        let requestsVM = FriendRequestsVM(friendManager: meManager, userRepository: directory,
                                          currentUserProvider: meProvider)
        await requestsVM.load()
        XCTAssertEqual(requestsVM.requests.count, 1)

        await requestsVM.decline(carol)
        XCTAssertTrue(requestsVM.requests.isEmpty)

        let isFriend = try await meManager.isFriend(targetUserId: "carol")
        XCTAssertFalse(isFriend)
    }

    // MARK: - 3. Multiple requesters — accept one, other remains

    func test_multipleRequests_acceptOne_leavesOther() async throws {
        var dave = UserProfile(id: "dave"); dave.name = "Dave"
        var eve  = UserProfile(id: "eve");  eve.name  = "Eve"
        directory.register(dave); directory.register(eve)

        let meProvider  = makeProvider("me")
        let meManager   = FriendManager(repository: repository, currentUserProvider: meProvider)
        try await FriendManager(repository: repository, currentUserProvider: makeProvider("dave"))
            .addFriend(targetUserId: "me", isTargetPrivate: true)
        try await FriendManager(repository: repository, currentUserProvider: makeProvider("eve"))
            .addFriend(targetUserId: "me", isTargetPrivate: true)

        let ownVM = OwnProfileVM(userId: "me", userRepository: directory,
                                  friendManager: meManager, currentUserProvider: meProvider)
        await ownVM.load()
        XCTAssertEqual(ownVM.pendingFriendsRequestCount, 2)

        let requestsVM = FriendRequestsVM(friendManager: meManager, userRepository: directory,
                                          currentUserProvider: meProvider)
        await requestsVM.load()
        let idsBefore = Set(requestsVM.requests.map(\.id))
        XCTAssertEqual(idsBefore, Set(["dave", "eve"]))

        await requestsVM.accept(dave)
        XCTAssertEqual(requestsVM.requests.map(\.id), ["eve"])

        await ownVM.load()
        XCTAssertEqual(ownVM.pendingFriendsRequestCount, 1)
    }
}
