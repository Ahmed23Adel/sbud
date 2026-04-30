//
//  FriendRepository.swift
//  sbud
//
//  Created by Erdal on 29.04.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendRepository {

    private let db = Firestore.firestore()

    // MARK: - Direct Add (açık hesap — onay yok)
    func addFriendDirectly(fromUserId: String, toUserId: String) async throws {
        let batch = db.batch()

        let myFriendRef = db
            .collection("users").document(fromUserId)
            .collection("friends").document(toUserId)
        batch.setData(["createdAt": Timestamp()], forDocument: myFriendRef)

        let theirFriendRef = db
            .collection("users").document(toUserId)
            .collection("friends").document(fromUserId)
        batch.setData(["createdAt": Timestamp()], forDocument: theirFriendRef)

        let myRef = db.collection("users").document(fromUserId)
        batch.updateData(["friendsCount": FieldValue.increment(Int64(1))], forDocument: myRef)

        let targetRef = db.collection("users").document(toUserId)
        batch.updateData(["friendsCount": FieldValue.increment(Int64(1))], forDocument: targetRef)

        try await batch.commit()
    }

    // MARK: - Send Friend Request (kapalı hesap — onay bekler)
    func sendFriendRequest(fromUserId: String, toUserId: String) async throws {
        let requestRef = db
            .collection("users").document(toUserId)
            .collection("friendRequests").document(fromUserId)
        try await requestRef.setData([
            "requesterId": fromUserId,
            "createdAt": Timestamp(),
            "status": "pending"
        ])
    }

    // MARK: - Cancel Sent Request
    func cancelFriendRequest(fromUserId: String, toUserId: String) async throws {
        let requestRef = db
            .collection("users").document(toUserId)
            .collection("friendRequests").document(fromUserId)
        try await requestRef.delete()
    }

    // MARK: - Accept Friend Request (kapalı hesap sahibi kabul eder → bidirectional friends)
    func acceptFriendRequest(currentUserId: String, requesterId: String) async throws {
        let batch = db.batch()

        let requestRef = db
            .collection("users").document(currentUserId)
            .collection("friendRequests").document(requesterId)
        batch.deleteDocument(requestRef)

        let myFriendRef = db
            .collection("users").document(currentUserId)
            .collection("friends").document(requesterId)
        batch.setData(["createdAt": Timestamp()], forDocument: myFriendRef)

        let theirFriendRef = db
            .collection("users").document(requesterId)
            .collection("friends").document(currentUserId)
        batch.setData(["createdAt": Timestamp()], forDocument: theirFriendRef)

        let myRef = db.collection("users").document(currentUserId)
        batch.updateData(["friendsCount": FieldValue.increment(Int64(1))], forDocument: myRef)

        let requesterRef = db.collection("users").document(requesterId)
        batch.updateData(["friendsCount": FieldValue.increment(Int64(1))], forDocument: requesterRef)

        try await batch.commit()
    }

    // MARK: - Decline Friend Request
    func declineFriendRequest(currentUserId: String, requesterId: String) async throws {
        let requestRef = db
            .collection("users").document(currentUserId)
            .collection("friendRequests").document(requesterId)
        try await requestRef.delete()
    }

    // MARK: - Remove Friend (bidirectional)
    func removeFriend(currentUserId: String, targetUserId: String) async throws {
        let batch = db.batch()

        let myFriendRef = db
            .collection("users").document(currentUserId)
            .collection("friends").document(targetUserId)
        batch.deleteDocument(myFriendRef)

        let theirFriendRef = db
            .collection("users").document(targetUserId)
            .collection("friends").document(currentUserId)
        batch.deleteDocument(theirFriendRef)

        let myRef = db.collection("users").document(currentUserId)
        batch.updateData(["friendsCount": FieldValue.increment(Int64(-1))], forDocument: myRef)

        let targetRef = db.collection("users").document(targetUserId)
        batch.updateData(["friendsCount": FieldValue.increment(Int64(-1))], forDocument: targetRef)

        try await batch.commit()
    }

    // MARK: - Status Checks

    func isFriend(currentUserId: String, targetUserId: String) async throws -> Bool {
        let doc = try await db
            .collection("users").document(currentUserId)
            .collection("friends").document(targetUserId)
            .getDocument()
        return doc.exists
    }

    func hasSentRequest(fromUserId: String, toUserId: String) async throws -> Bool {
        let doc = try await db
            .collection("users").document(toUserId)
            .collection("friendRequests").document(fromUserId)
            .getDocument()
        return doc.exists
    }

    func hasReceivedRequest(currentUserId: String, fromUserId: String) async throws -> Bool {
        let doc = try await db
            .collection("users").document(currentUserId)
            .collection("friendRequests").document(fromUserId)
            .getDocument()
        return doc.exists
    }

    func getFriendStatus(currentUserId: String, targetUserId: String) async throws -> FriendStatus {
        if try await isFriend(currentUserId: currentUserId, targetUserId: targetUserId) {
            return .friends
        }
        if try await hasSentRequest(fromUserId: currentUserId, toUserId: targetUserId) {
            return .requestSent
        }
        if try await hasReceivedRequest(currentUserId: currentUserId, fromUserId: targetUserId) {
            return .requestReceived
        }
        return .notFriend
    }

    // MARK: - Fetch Lists

    func fetchFriends(userId: String) async throws -> [String] {
        let snapshot = try await db
            .collection("users").document(userId)
            .collection("friends")
            .getDocuments()
        return snapshot.documents.map { $0.documentID }
    }

    func fetchPendingRequests(userId: String) async throws -> [String] {
        let snapshot = try await db
            .collection("users").document(userId)
            .collection("friendRequests")
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        return snapshot.documents.map { $0.documentID }
    }
}
