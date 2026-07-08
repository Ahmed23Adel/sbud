//
//  FriendManagerIntegrationTests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest
@testable import sbud

// MARK: - FakeFriendRepository

final class FakeFriendRepository: IFriendRepository {

    private var friends: Set<String> = []
    private var pendingRequests: [String: Set<String>] = [:]

    private func pairKey(_ a: String, _ b: String) -> String {
        [a, b].sorted().joined(separator: "|")
    }

    func addFriendDirectly(fromUserId: String, toUserId: String) async throws {
        friends.insert(pairKey(fromUserId, toUserId))
    }

    func sendFriendRequest(fromUserId: String, toUserId: String) async throws {
        pendingRequests[toUserId, default: []].insert(fromUserId)
    }

    func cancelFriendRequest(fromUserId: String, toUserId: String) async throws {
        pendingRequests[toUserId]?.remove(fromUserId)
    }

    func acceptFriendRequest(currentUserId: String, requesterId: String) async throws {
        pendingRequests[currentUserId]?.remove(requesterId)
        friends.insert(pairKey(currentUserId, requesterId))
    }

    func declineFriendRequest(currentUserId: String, requesterId: String) async throws {
        pendingRequests[currentUserId]?.remove(requesterId)
    }

    func removeFriend(currentUserId: String, targetUserId: String) async throws {
        friends.remove(pairKey(currentUserId, targetUserId))
    }

    func isFriend(currentUserId: String, targetUserId: String) async throws -> Bool {
        friends.contains(pairKey(currentUserId, targetUserId))
    }

    func hasSentRequest(fromUserId: String, toUserId: String) async throws -> Bool {
        pendingRequests[toUserId]?.contains(fromUserId) ?? false
    }

    func hasReceivedRequest(currentUserId: String, fromUserId: String) async throws -> Bool {
        pendingRequests[currentUserId]?.contains(fromUserId) ?? false
    }

    func getFriendStatus(currentUserId: String, targetUserId: String) async throws -> FriendStatus {
        if try await isFriend(currentUserId: currentUserId, targetUserId: targetUserId) { return .friends }
        if try await hasSentRequest(fromUserId: currentUserId, toUserId: targetUserId) { return .requestSent }
        if try await hasReceivedRequest(currentUserId: currentUserId, fromUserId: targetUserId) { return .requestReceived }
        return .notFriend
    }

    func fetchFriends(userId: String) async throws -> [String] {
        friends.compactMap { pair -> String? in
            let parts = pair.split(separator: "|").map(String.init)
            guard parts.contains(userId) else { return nil }
            return parts.first { $0 != userId }
        }
    }

    func fetchPendingFriendsRequests(userId: String) async throws -> [String] {
        Array(pendingRequests[userId] ?? [])
    }

    func fetchPendingHostsRequests(userId: String) async throws -> [String] { [] }
}

// MARK: - FriendManagerIntegrationTests

@MainActor
final class FriendManagerIntegrationTests: XCTestCase {

    private var repository: FakeFriendRepository!

    override func setUp() {
        super.setUp()
        repository = FakeFriendRepository()
    }

    override func tearDown() {
        repository = nil
        super.tearDown()
    }

    private func makeManager(currentUserId: String?) -> FriendManager {
        let provider = MockCurrentUserProvider()
        provider.currentUserId = currentUserId
        return FriendManager(repository: repository, currentUserProvider: provider)
    }

    // MARK: - 1. Open account: addFriend is immediate and bidirectional

    func test_openAccount_addFriend_isImmediatelyMutualFromBothSides() async throws {
        let alice = makeManager(currentUserId: "alice")
        let bob   = makeManager(currentUserId: "bob")

        try await alice.addFriend(targetUserId: "bob", isTargetPrivate: false)

        let aliceSeesBob = try await alice.isFriend(targetUserId: "bob")
        let bobSeesAlice = try await bob.isFriend(targetUserId: "alice")

        XCTAssertTrue(aliceSeesBob)
        XCTAssertTrue(bobSeesAlice)
    }

    // MARK: - 2. Private account: full request → accept lifecycle

    func test_privateAccount_sendThenAccept_resultInFriendship() async throws {
        let alice = makeManager(currentUserId: "alice")
        let bob   = makeManager(currentUserId: "bob")

        try await alice.addFriend(targetUserId: "bob", isTargetPrivate: true)

        let aliceStatusAfterRequest = try await alice.getFriendStatus(targetUserId: "bob")
        let bobStatusAfterRequest   = try await bob.getFriendStatus(targetUserId: "alice")
        XCTAssertEqual(aliceStatusAfterRequest, .requestSent)
        XCTAssertEqual(bobStatusAfterRequest, .requestReceived)

        try await bob.acceptRequest(requesterId: "alice")

        let aliceStatusAfterAccept = try await alice.getFriendStatus(targetUserId: "bob")
        let bobStatusAfterAccept   = try await bob.getFriendStatus(targetUserId: "alice")
        XCTAssertEqual(aliceStatusAfterAccept, .friends)
        XCTAssertEqual(bobStatusAfterAccept, .friends)

        let aliceFriends = try await alice.fetchFriends(userId: "alice")
        XCTAssertEqual(aliceFriends, ["bob"])
    }

    func test_privateAccount_declinedRequest_leavesBothAsNotFriends() async throws {
        let alice = makeManager(currentUserId: "alice")
        let bob   = makeManager(currentUserId: "bob")

        try await alice.addFriend(targetUserId: "bob", isTargetPrivate: true)
        try await bob.declineRequest(requesterId: "alice")

        let aliceStatus = try await alice.getFriendStatus(targetUserId: "bob")
        let bobStatus   = try await bob.getFriendStatus(targetUserId: "alice")
        XCTAssertEqual(aliceStatus, .notFriend)
        XCTAssertEqual(bobStatus, .notFriend)
    }

    func test_privateAccount_cancelledRequest_clearsPendingState() async throws {
        let alice = makeManager(currentUserId: "alice")

        try await alice.addFriend(targetUserId: "bob", isTargetPrivate: true)
        let statusAfterRequest = try await alice.getFriendStatus(targetUserId: "bob")
        XCTAssertEqual(statusAfterRequest, .requestSent)

        try await alice.cancelRequest(targetUserId: "bob")
        let statusAfterCancel = try await alice.getFriendStatus(targetUserId: "bob")
        XCTAssertEqual(statusAfterCancel, .notFriend)
    }

    // MARK: - 3. removeFriend breaks relationship symmetrically

    func test_removeFriend_breaksRelationshipForBothSides() async throws {
        let alice = makeManager(currentUserId: "alice")
        let bob   = makeManager(currentUserId: "bob")

        try await alice.addFriend(targetUserId: "bob", isTargetPrivate: false)

        let isFriendBefore = try await alice.isFriend(targetUserId: "bob")
        XCTAssertTrue(isFriendBefore)

        try await alice.removeFriend(targetUserId: "bob")

        let aliceStillFriend = try await alice.isFriend(targetUserId: "bob")
        let bobStillFriend   = try await bob.isFriend(targetUserId: "alice")
        XCTAssertFalse(aliceStillFriend)
        XCTAssertFalse(bobStillFriend)
    }

    // MARK: - 4. Pending requests (badge counts)

    func test_fetchFriendsPendingRequests_reflectsIncomingRequests() async throws {
        let alice = makeManager(currentUserId: "alice")
        let bob   = makeManager(currentUserId: "bob")
        let carol = makeManager(currentUserId: "carol")

        try await alice.addFriend(targetUserId: "carol", isTargetPrivate: true)
        try await bob.addFriend(targetUserId: "carol", isTargetPrivate: true)

        let carolPending = try await carol.fetchFriendsPendingRequests(userId: "carol")
        XCTAssertEqual(Set(carolPending), Set(["alice", "bob"]))
    }

    func test_fetchHostsPendingRequests_returnsEmpty() async throws {
        let alice = makeManager(currentUserId: "alice")
        let result = try await alice.fetchHostsPendingRequests(userId: "alice")
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - 5. Auth guard holds after sign-out

    func test_userSignsOutBetweenCalls_subsequentMutationsAreBlocked() async throws {
        let provider = MockCurrentUserProvider()
        provider.currentUserId = "alice"
        let sut = FriendManager(repository: repository, currentUserProvider: provider)

        try await sut.addFriend(targetUserId: "bob", isTargetPrivate: false)
        let isFriendBeforeSignOut = try await sut.isFriend(targetUserId: "bob")
        XCTAssertTrue(isFriendBeforeSignOut)

        provider.currentUserId = nil

        do {
            try await sut.removeFriend(targetUserId: "bob")
            XCTFail("Expected notAuthenticated after sign-out")
        } catch let error as FriendError {
            XCTAssertEqual(error.errorDescription, FriendError.notAuthenticated.errorDescription)
        }

        provider.currentUserId = "alice"
        let isFriendAfterSignOut = try await sut.isFriend(targetUserId: "bob")
        XCTAssertTrue(isFriendAfterSignOut)
    }

    // MARK: - 6. Cannot add self

    func test_cannotAddSelf_repositoryNeverInvoked() async throws {
        let alice = makeManager(currentUserId: "alice")

        do {
            try await alice.addFriend(targetUserId: "alice", isTargetPrivate: false)
            XCTFail("Expected cannotAddSelf")
        } catch let error as FriendError {
            XCTAssertEqual(error.errorDescription, FriendError.cannotAddSelf.errorDescription)
        }

        let aliceFriends = try await alice.fetchFriends(userId: "alice")
        XCTAssertTrue(aliceFriends.isEmpty)
    }
}
