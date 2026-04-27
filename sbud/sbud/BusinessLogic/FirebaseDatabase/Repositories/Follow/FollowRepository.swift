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

    // MARK: - Follow
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

    func isFollowing(currentUserId: String, targetUserId: String) async throws -> Bool {
        let doc = try await db
            .collection("users").document(currentUserId)
            .collection("following").document(targetUserId)
            .getDocument()
        return doc.exists
    }


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
}
