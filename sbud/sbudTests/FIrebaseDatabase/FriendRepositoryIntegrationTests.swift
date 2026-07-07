//
//  FriendRepositoryIntegrationTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 07/07/2026.
//


import XCTest
import FirebaseCore
import FirebaseFirestore
@testable import sbud

//ricordarsi di attivare emulatore firebase
final class FriendRepositoryIntegrationTests: XCTestCase {

    var sut: FriendRepository!
    let userA = "user_A"
    let userB = "user_B"

    override func setUp() async throws {
        try await super.setUp()
        try await clearEmulatorFirestore()
        sut = FriendRepository()

        // Creiamo i documenti utente con friendsCount, perché updateData
        // con increment fallisce se il documento non esiste
        let db = Firestore.firestore()
        try await db.collection("users").document(userA).setData(["friendsCount": 0])
        try await db.collection("users").document(userB).setData(["friendsCount": 0])
    }

    private func clearEmulatorFirestore() async throws {
        guard let projectId = FirebaseApp.app()?.options.projectID else { return }
        let url = URL(string: "http://localhost:8080/emulator/v1/projects/\(projectId)/databases/(default)/documents")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try await URLSession.shared.data(for: request)
    }

    private func friendsCount(of userId: String) async throws -> Int {
        let doc = try await Firestore.firestore().collection("users").document(userId).getDocument()
        return doc.data()?["friendsCount"] as? Int ?? -1
    }

    // MARK: - addFriendDirectly

    func test_addFriendDirectly_createsBidirectionalFriendship() async throws {
        try await sut.addFriendDirectly(fromUserId: userA, toUserId: userB)

        let aSeesB = try await sut.isFriend(currentUserId: userA, targetUserId: userB)
        let bSeesA = try await sut.isFriend(currentUserId: userB, targetUserId: userA)
        XCTAssertTrue(aSeesB, "A deve avere B tra gli amici")
        XCTAssertTrue(bSeesA, "B deve avere A tra gli amici (bidirezionale)")
    }

    func test_addFriendDirectly_incrementsBothCounters() async throws {
        try await sut.addFriendDirectly(fromUserId: userA, toUserId: userB)

        let countA = try await friendsCount(of: userA)
        let countB = try await friendsCount(of: userB)
        XCTAssertEqual(countA, 1)
        XCTAssertEqual(countB, 1)
    }

    // MARK: - Friend Requests

    func test_sendFriendRequest_createsPendingRequest() async throws {
        try await sut.sendFriendRequest(fromUserId: userA, toUserId: userB)

        let received = try await sut.hasReceivedRequest(currentUserId: userB, fromUserId: userA)
        let sent = try await sut.hasSentRequest(fromUserId: userA, toUserId: userB)
        XCTAssertTrue(received)
        XCTAssertTrue(sent)

        let pending = try await sut.fetchPendingFriendsRequests(userId: userB)
        XCTAssertEqual(pending, [userA])
    }

    func test_sendFriendRequest_doesNotMakeThemFriendsYet() async throws {
        try await sut.sendFriendRequest(fromUserId: userA, toUserId: userB)

        let areFriends = try await sut.isFriend(currentUserId: userA, targetUserId: userB)
        XCTAssertFalse(areFriends, "La richiesta pendente non è ancora un'amicizia")
    }

    func test_cancelFriendRequest_removesRequest() async throws {
        try await sut.sendFriendRequest(fromUserId: userA, toUserId: userB)

        try await sut.cancelFriendRequest(fromUserId: userA, toUserId: userB)

        let stillThere = try await sut.hasReceivedRequest(currentUserId: userB, fromUserId: userA)
        XCTAssertFalse(stillThere)
    }

    func test_acceptFriendRequest_makesFriendsAndRemovesRequest() async throws {
        try await sut.sendFriendRequest(fromUserId: userA, toUserId: userB)

        try await sut.acceptFriendRequest(currentUserId: userB, requesterId: userA)

        let areFriends = try await sut.isFriend(currentUserId: userB, targetUserId: userA)
        let reverse = try await sut.isFriend(currentUserId: userA, targetUserId: userB)
        let requestGone = try await sut.hasReceivedRequest(currentUserId: userB, fromUserId: userA)
        XCTAssertTrue(areFriends)
        XCTAssertTrue(reverse)
        XCTAssertFalse(requestGone, "La richiesta deve sparire dopo l'accettazione")

        let countA = try await friendsCount(of: userA)
        XCTAssertEqual(countA, 1)
    }

    func test_declineFriendRequest_removesRequestWithoutFriendship() async throws {
        try await sut.sendFriendRequest(fromUserId: userA, toUserId: userB)

        try await sut.declineFriendRequest(currentUserId: userB, requesterId: userA)

        let requestGone = try await sut.hasReceivedRequest(currentUserId: userB, fromUserId: userA)
        let areFriends = try await sut.isFriend(currentUserId: userB, targetUserId: userA)
        XCTAssertFalse(requestGone)
        XCTAssertFalse(areFriends)
    }

    // MARK: - removeFriend

    func test_removeFriend_removesBothSidesAndDecrementsCounters() async throws {
        try await sut.addFriendDirectly(fromUserId: userA, toUserId: userB)

        try await sut.removeFriend(currentUserId: userA, targetUserId: userB)

        let aSeesB = try await sut.isFriend(currentUserId: userA, targetUserId: userB)
        let bSeesA = try await sut.isFriend(currentUserId: userB, targetUserId: userA)
        XCTAssertFalse(aSeesB)
        XCTAssertFalse(bSeesA)

        let countA = try await friendsCount(of: userA)
        let countB = try await friendsCount(of: userB)
        XCTAssertEqual(countA, 0, "Il contatore deve tornare a 0 dopo la rimozione")
        XCTAssertEqual(countB, 0)
    }

    // MARK: - getFriendStatus (tutti gli stati)

    func test_getFriendStatus_notFriend() async throws {
        let status = try await sut.getFriendStatus(currentUserId: userA, targetUserId: userB)
        XCTAssertEqual(status, .notFriend)
    }

    func test_getFriendStatus_requestSent() async throws {
        try await sut.sendFriendRequest(fromUserId: userA, toUserId: userB)
        let status = try await sut.getFriendStatus(currentUserId: userA, targetUserId: userB)
        XCTAssertEqual(status, .requestSent)
    }

    func test_getFriendStatus_requestReceived() async throws {
        try await sut.sendFriendRequest(fromUserId: userB, toUserId: userA)
        let status = try await sut.getFriendStatus(currentUserId: userA, targetUserId: userB)
        XCTAssertEqual(status, .requestReceived)
    }

    func test_getFriendStatus_friends() async throws {
        try await sut.addFriendDirectly(fromUserId: userA, toUserId: userB)
        let status = try await sut.getFriendStatus(currentUserId: userA, targetUserId: userB)
        XCTAssertEqual(status, .friends)
    }

    // MARK: - fetchFriends

    func test_fetchFriends_returnsAllFriendIds() async throws {
        let userC = "user_C"
        try await Firestore.firestore().collection("users").document(userC).setData(["friendsCount": 0])
        try await sut.addFriendDirectly(fromUserId: userA, toUserId: userB)
        try await sut.addFriendDirectly(fromUserId: userA, toUserId: userC)

        let friends = try await sut.fetchFriends(userId: userA)

        XCTAssertEqual(Set(friends), Set([userB, userC]))
    }

    func test_fetchFriends_noFriends_returnsEmpty() async throws {
        let friends = try await sut.fetchFriends(userId: userA)
        XCTAssertTrue(friends.isEmpty)
    }
}
