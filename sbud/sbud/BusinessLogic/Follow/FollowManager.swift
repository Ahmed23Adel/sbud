//
//  FollowManager.swift
//  sbud
//
//  Created by Erdal on 27.04.2026.
//

import Foundation
import FirebaseAuth

class FollowManager {

    static let shared = FollowManager()
    private let repository = FollowRepository()
    private init() {}

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func follow(targetUserId: String) async throws {
        guard let currentId = currentUserId else { throw FollowError.notAuthenticated }
        guard currentId != targetUserId else { throw FollowError.cannotFollowSelf }
        try await repository.follow(currentUserId: currentId, targetUserId: targetUserId)
    }

    // MARK: - Unfollow
    func unfollow(targetUserId: String) async throws {
        guard let currentId = currentUserId else { throw FollowError.notAuthenticated }
        try await repository.unfollow(currentUserId: currentId, targetUserId: targetUserId)
    }

    func isFollowing(targetUserId: String) async throws -> Bool {
        guard let currentId = currentUserId else { return false }
        return try await repository.isFollowing(currentUserId: currentId, targetUserId: targetUserId)
    }

    func fetchFollowers(userId: String) async throws -> [String] {
        try await repository.fetchFollowers(userId: userId)
    }

    func fetchFollowing(userId: String) async throws -> [String] {
        try await repository.fetchFollowing(userId: userId)
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
