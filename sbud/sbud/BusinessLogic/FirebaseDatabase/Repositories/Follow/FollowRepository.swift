//
//  FollowRepository.swift
//  sbud
//
//  Created by Erdal on 27.04.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FollowRepository {

    private let db = Firestore.firestore()

    // MARK: - Follow (Public Account)
    func follow(currentUserId: String, targetUserId: String) async throws {
        let batch = db.batch()

        let followingRef = db
            .collection("users").document(currentUserId)
            .collection("following").document(targetUserId)
        batch.setData(["createdAt": Timestamp()], forDocument: followingRef)

        let followerRef = db
            .collection("users").document(targetUserId)
            .collection("followers").document(currentUserId)
        batch.setData(["createdAt": Timestamp()], forDocument: followerRef)

        let targetUserRef = db.collection("users").document(targetUserId)
        batch.updateData(["followersCount": FieldValue.increment(Int64(1))], forDocument: targetUserRef)

        let currentUserRef = db.collection("users").document(currentUserId)
        batch.updateData(["followingCount": FieldValue.increment(Int64(1))], forDocument: currentUserRef)

        try await batch.commit()
    }

    // MARK: - Unfollow
    func unfollow(currentUserId: String, targetUserId: String) async throws {
        let batch = db.batch()

        let followingRef = db
            .collection("users").document(currentUserId)
            .collection("following").document(targetUserId)
        batch.deleteDocument(followingRef)

        let followerRef = db
            .collection("users").document(targetUserId)
            .collection("followers").document(currentUserId)
        batch.deleteDocument(followerRef)

        let targetUserRef = db.collection("users").document(targetUserId)
        batch.updateData(["followersCount": FieldValue.increment(Int64(-1))], forDocument: targetUserRef)

        let currentUserRef = db.collection("users").document(currentUserId)
        batch.updateData(["followingCount": FieldValue.increment(Int64(-1))], forDocument: currentUserRef)

        try await batch.commit()
    }

    // MARK: - Send Follow Request (Private Account)
    func sendFollowRequest(currentUserId: String, targetUserId: String) async throws {
        let requestRef = db
            .collection("users").document(targetUserId)
            .collection("followRequests").document(currentUserId)
        try await requestRef.setData([
            "requesterId": currentUserId,
            "createdAt": Timestamp(),
            "status": "pending"
        ])
    }

    // MARK: - Cancel Follow Request
    func cancelFollowRequest(currentUserId: String, targetUserId: String) async throws {
        let requestRef = db
            .collection("users").document(targetUserId)
            .collection("followRequests").document(currentUserId)
        try await requestRef.delete()
    }

    // MARK: - Accept Follow Request
    func acceptFollowRequest(currentUserId: String, requesterId: String) async throws {
        let batch = db.batch()

        let requestRef = db
            .collection("users").document(currentUserId)
            .collection("followRequests").document(requesterId)
        batch.deleteDocument(requestRef)

        let followingRef = db
            .collection("users").document(requesterId)
            .collection("following").document(currentUserId)
        batch.setData(["createdAt": Timestamp()], forDocument: followingRef)

        let followerRef = db
            .collection("users").document(currentUserId)
            .collection("followers").document(requesterId)
        batch.setData(["createdAt": Timestamp()], forDocument: followerRef)

        let currentUserRef = db.collection("users").document(currentUserId)
        batch.updateData(["followersCount": FieldValue.increment(Int64(1))], forDocument: currentUserRef)

        let requesterRef = db.collection("users").document(requesterId)
        batch.updateData(["followingCount": FieldValue.increment(Int64(1))], forDocument: requesterRef)

        try await batch.commit()
    }

    // MARK: - Decline Follow Request (hesap sahibi çağırır)
    func declineFollowRequest(currentUserId: String, requesterId: String) async throws {
        let requestRef = db
            .collection("users").document(currentUserId)
            .collection("followRequests").document(requesterId)
        try await requestRef.delete()
    }

    // MARK: - Status Checks

    func isFollowing(currentUserId: String, targetUserId: String) async throws -> Bool {
        let doc = try await db
            .collection("users").document(currentUserId)
            .collection("following").document(targetUserId)
            .getDocument()
        return doc.exists
    }

    func hasPendingRequest(currentUserId: String, targetUserId: String) async throws -> Bool {
        let doc = try await db
            .collection("users").document(targetUserId)
            .collection("followRequests").document(currentUserId)
            .getDocument()
        return doc.exists
    }

    // MARK: - Fetch Lists

    func fetchFollowers(userId: String) async throws -> [String] {
        let snapshot = try await db
            .collection("users").document(userId)
            .collection("followers")
            .getDocuments()
        return snapshot.documents.map { $0.documentID }
    }

    func fetchFollowing(userId: String) async throws -> [String] {
        let snapshot = try await db
            .collection("users").document(userId)
            .collection("following")
            .getDocuments()
        return snapshot.documents.map { $0.documentID }
    }

    func fetchPendingRequests(userId: String) async throws -> [String] {
        let snapshot = try await db
            .collection("users").document(userId)
            .collection("followRequests")
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        return snapshot.documents.map { $0.documentID }
    }
}
