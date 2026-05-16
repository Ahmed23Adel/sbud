//
//  FriendManager.swift
//  sbud
//
//  Created by Erdal on 29.04.2026.
//

import Foundation
import FirebaseAuth

// MARK: - Friend Status
enum FriendStatus: Equatable {
    case notFriend
    case requestSent
    case requestReceived
    case friends
}

// MARK: - FriendManager
class FriendManager {

    static let shared = FriendManager()
    private let repository = FriendRepository()
    private init() {}

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func addFriend(targetUserId: String, isTargetPrivate: Bool) async throws {
        guard let currentId = currentUserId else { throw FriendError.notAuthenticated }
        guard currentId != targetUserId else { throw FriendError.cannotAddSelf }

        if isTargetPrivate {
            try await repository.sendFriendRequest(fromUserId: currentId, toUserId: targetUserId)
        } else {
            try await repository.addFriendDirectly(fromUserId: currentId, toUserId: targetUserId)
        }
    }

    func cancelRequest(targetUserId: String) async throws {
        guard let currentId = currentUserId else { throw FriendError.notAuthenticated }
        try await repository.cancelFriendRequest(fromUserId: currentId, toUserId: targetUserId)
    }


    func acceptRequest(requesterId: String) async throws {
        guard let currentId = currentUserId else { throw FriendError.notAuthenticated }
        try await repository.acceptFriendRequest(currentUserId: currentId, requesterId: requesterId)
    }

    func declineRequest(requesterId: String) async throws {
        guard let currentId = currentUserId else { throw FriendError.notAuthenticated }
        try await repository.declineFriendRequest(currentUserId: currentId, requesterId: requesterId)
    }

    func removeFriend(targetUserId: String) async throws {
        guard let currentId = currentUserId else { throw FriendError.notAuthenticated }
        try await repository.removeFriend(currentUserId: currentId, targetUserId: targetUserId)
    }

    func getFriendStatus(targetUserId: String) async throws -> FriendStatus {
        guard let currentId = currentUserId else { return .notFriend }
        return try await repository.getFriendStatus(currentUserId: currentId, targetUserId: targetUserId)
    }

    func isFriend(targetUserId: String) async throws -> Bool {
        guard let currentId = currentUserId else { return false }
        return try await repository.isFriend(currentUserId: currentId, targetUserId: targetUserId)
    }

    func fetchFriends(userId: String) async throws -> [String] {
        try await repository.fetchFriends(userId: userId)
    }

    func fetchFriendsPendingRequests(userId: String) async throws -> [String] {
        try await repository.fetchPendingFriendsRequests(userId: userId)
    }
    
    func fetchHostsPendingRequests(userId: String) async throws -> [String] {
        try await repository.fetchPendingHostsRequests(userId: userId)
    }
    
    
}

enum FriendError: LocalizedError {
    case notAuthenticated
    case cannotAddSelf

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "User not authenticated."
        case .cannotAddSelf: return "You cannot add yourself as a friend."
        }
    }
}
