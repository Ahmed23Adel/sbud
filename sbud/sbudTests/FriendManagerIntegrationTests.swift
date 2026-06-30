//
//  FriendManagerIntegrationTests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest
@testable import sbud

// MARK: - FakeFriendRepository (stateful, mirrors FriendRepository's real semantics)

final class FakeFriendRepository: IFriendRepository {

    private var friends: Set<String> = []          // "userA|userB" pairs, order-independent
    private var pendingRequests: [String: Set<String>] = [:] // toUserId -> set of fromUserIds

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

    func fetchPendingHostsRequests(userId: String) async throws -> [String] {
        [] // not modeled — FriendManager only forwards this call untouched
    }
}

// MARK: - FriendManagerIntegrationTests

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

    // MARK: - 1. Open Account: addFriend Is Immediate and Bidirectional

    func test_openAccount_addFriend_isImmediatelyMutualFromBothSides() async throws {
        let alice = makeManager(currentUserId: "alice")
        let bob = makeManager(currentUserId: "bob")

        try await alice.addFriend(targetUserId: "bob", isTargetPrivate: false)

        let aliceSeesBob = try await alice.isFriend(targetUserId: "bob")
        let bobSeesAlice = try await bob.isFriend(targetUserId: "alice")

        XCTAssertTrue(aliceSeesBob)
        XCTAssertTrue(bobSeesAlice, "Friendship should be symmetric, mirroring FriendRepository's batched bidirectional write")
    }

    // MARK: - 2. Private Account: Full Request -> Accept Lifecycle

    func test_privateAccount_fullLifecycle_sendThenAcceptResultsInFriendship() async throws {
        let alice = makeManager(currentUserId: "alice")
        let bob = makeManager(currentUserId: "bob")

        // 1. Alice sends a request (bob's account is private).
        try await alice.addFriend(targetUserId: "bob", isTargetPrivate: true)
        var aliceStatus = try await alice.getFriendStatus(targetUserId: "bob")
        var bobStatus = try await bob.getFriendStatus(targetUserId: "alice")
        XCTAssertEqual(aliceStatus, .requestSent)
        XCTAssertEqual(bobStatus, .requestReceived)

        // 2. Bob accepts.
        try await bob.acceptRequest(requesterId: "alice")

        aliceStatus = try await alice.getFriendStatus(targetUserId: "bob")
        bobStatus = try await bob.getFriendStatus(targetUserId: "alice")
        XCTAssertEqual(aliceStatus, .friends)
        XCTAssertEqual(bobStatus, .friends)

        let aliceFriends = try await alice.fetchFriends(userId: "alice")
        XCTAssertEqual(aliceFriends, ["bob"])
    }

    func test_privateAccount_declinedRequest_leavesBothAsNotFriends() async throws {
        let alice = makeManager(currentUserId: "alice")
        let bob = makeManager(currentUserId: "bob")

        try await alice.addFriend(targetUserId: "bob", isTargetPrivate: true)
        try await bob.declineRequest(requesterId: "alice")

        let aliceStatus = try await alice.getFriendStatus(targetUserId: "bob")
        let bobStatus = try await bob.getFriendStatus(targetUserId: "alice")
        XCTAssertEqual(aliceStatus, .notFriend)
        XCTAssertEqual(bobStatus, .notFriend)
    }

    func test_privateAccount_cancelledRequest_clearsPendingState() async throws {
        let alice = makeManager(currentUserId: "alice")

        try await alice.addFriend(targetUserId: "bob", isTargetPrivate: true)
        XCTAssertEqual(try await alice.getFriendStatus(targetUserId: "bob"), .requestSent)

        try await alice.cancelRequest(targetUserId: "bob")
        XCTAssertEqual(try await alice.getFriendStatus(targetUserId: "bob"), .notFriend)
    }

    // MARK: - 3. removeFriend Breaks the Relationship Symmetrically

    func test_removeFriend_breaksRelationshipForBothSides() async throws {
        let alice = makeManager(currentUserId: "alice")
        let bob = makeManager(currentUserId: "bob")

        try await alice.addFriend(targetUserId: "bob", isTargetPrivate: false)
        XCTAssertTrue(try await alice.isFriend(targetUserId: "bob"))

        try await alice.removeFriend(targetUserId: "bob")

        XCTAssertFalse(try await alice.isFriend(targetUserId: "bob"))
        XCTAssertFalse(try await bob.isFriend(targetUserId: "alice"))
    }

    // MARK: - 4. fetchFriendsPendingRequests / fetchHostsPendingRequests (used by OwnProfileVM badges)

    func test_fetchFriendsPendingRequests_reflectsIncomingRequests() async throws {
        let alice = makeManager(currentUserId: "alice")
        let bob = makeManager(currentUserId: "bob")
        let carol = makeManager(currentUserId: "carol")

        try await alice.addFriend(targetUserId: "carol", isTargetPrivate: true)
        try await bob.addFriend(targetUserId: "carol", isTargetPrivate: true)

        let carolPending = try await carol.fetchFriendsPendingRequests(userId: "carol")
        XCTAssertEqual(Set(carolPending), Set(["alice", "bob"]))
    }

    func test_fetchHostsPendingRequests_delegatesThroughUnaffectedByFriendGraph() async throws {
        let alice = makeManager(currentUserId: "alice")
        let result = try await alice.fetchHostsPendingRequests(userId: "alice")
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - 5. Auth Guard Holds Across a Realistic Session Boundary (e.g. user signs out mid-flow)

    func test_userSignsOutBetweenCalls_subsequentMutationsAreBlocked() async throws {
        let provider = MockCurrentUserProvider()
        provider.currentUserId = "alice"
        let sut = FriendManager(repository: repository, currentUserProvider: provider)

        try await sut.addFriend(targetUserId: "bob", isTargetPrivate: false)
        XCTAssertTrue(try await sut.isFriend(targetUserId: "bob"))

        // Simulate sign-out.
        provider.currentUserId = nil

        do {
            try await sut.removeFriend(targetUserId: "bob")
            XCTFail("Expected notAuthenticated after sign-out")
        } catch let error as FriendError {
            XCTAssertEqual(error.errorDescription, FriendError.notAuthenticated.errorDescription)
        }

        // The friendship itself is untouched since the mutation never reached the repository.
        provider.currentUserId = "alice"
        XCTAssertTrue(try await sut.isFriend(targetUserId: "bob"))
    }

    // MARK: - 6. Cannot Add Self, Even With a Fully Wired Repository

    func test_cannotAddSelf_repositoryNeverInvoked() async {
        let alice = makeManager(currentUserId: "alice")
        do {
            try await alice.addFriend(targetUserId: "alice", isTargetPrivate: false)
            XCTFail("Expected cannotAddSelf")
        } catch let error as FriendError {
            XCTAssertEqual(error.errorDescription, FriendError.cannotAddSelf.errorDescription)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let aliceFriends = try? await alice.fetchFriends(userId: "alice")
        XCTAssertEqual(aliceFriends, [], "Repository state should be completely unaffected")
    }
}
