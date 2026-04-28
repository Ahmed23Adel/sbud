//
//  FollowManager.swift
//  sbud
//
//  Created by Erdal on 27.04.2026.
//

import Foundation
import FirebaseAuth

// MARK: - Follow Status
enum FollowStatus: Equatable {
    case notFollowing
    case pending
    case following
}

// MARK: - FollowManager
class FollowManager {

    static let shared = FollowManager()
    private let repository = FollowRepository()
    private init() {}

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func follow(targetUserId: String, isTargetPrivate: Bool) async throws {
        guard let currentId = currentUserId else { throw FollowError.notAuthenticated }
        guard currentId != targetUserId else { throw FollowError.cannotFollowSelf }

        if isTargetPrivate {
            try await repository.sendFollowRequest(currentUserId: currentId, targetUserId: targetUserId)
        } else {
            try await repository.follow(currentUserId: currentId, targetUserId: targetUserId)
        }
    }

    // MARK: - Unfollow
    func unfollow(targetUserId: String) async throws {
        guard let currentId = currentUserId else { throw FollowError.notAuthenticated }
        try await repository.unfollow(currentUserId: currentId, targetUserId: targetUserId)
    }

    // MARK: - Cancel Request
    func cancelRequest(targetUserId: String) async throws {
        guard let currentId = currentUserId else { throw FollowError.notAuthenticated }
        try await repository.cancelFollowRequest(currentUserId: currentId, targetUserId: targetUserId)
    }

    // MARK: - Accept / Decline
    func acceptRequest(requesterId: String) async throws {
        guard let currentId = currentUserId else { throw FollowError.notAuthenticated }
        try await repository.acceptFollowRequest(currentUserId: currentId, requesterId: requesterId)
    }

    func declineRequest(requesterId: String) async throws {
        guard let currentId = currentUserId else { throw FollowError.notAuthenticated }
        try await repository.declineFollowRequest(currentUserId: currentId, requesterId: requesterId)
    }

    // MARK: - Status Check
    func getFollowStatus(targetUserId: String) async throws -> FollowStatus {
        guard let currentId = currentUserId else { return .notFollowing }

        let following = try await repository.isFollowing(currentUserId: currentId, targetUserId: targetUserId)
        if following { return .following }

        let pending = try await repository.hasPendingRequest(currentUserId: currentId, targetUserId: targetUserId)
        return pending ? .pending : .notFollowing
    }

    func isFollowing(targetUserId: String) async throws -> Bool {
        guard let currentId = currentUserId else { return false }
        return try await repository.isFollowing(currentUserId: currentId, targetUserId: targetUserId)
    }

    // MARK: - Fetch Lists
    func fetchFollowers(userId: String) async throws -> [String] {
        try await repository.fetchFollowers(userId: userId)
    }

    func fetchFollowing(userId: String) async throws -> [String] {
        try await repository.fetchFollowing(userId: userId)
    }

    func fetchPendingRequests(userId: String) async throws -> [String] {
        try await repository.fetchPendingRequests(userId: userId)
    }
}

enum FollowError: LocalizedError {
    case notAuthenticated
    case cannotFollowSelf

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "User not authenticated."
        case .cannotFollowSelf: return "You cannot follow yourself."
        }
    }
}
