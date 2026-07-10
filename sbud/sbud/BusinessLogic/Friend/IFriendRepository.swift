//
//  IFriendRepository.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import Foundation

protocol IFriendRepository {
    func addFriendDirectly(fromUserId: String, toUserId: String) async throws
    func sendFriendRequest(fromUserId: String, toUserId: String) async throws
    func cancelFriendRequest(fromUserId: String, toUserId: String) async throws
    func acceptFriendRequest(currentUserId: String, requesterId: String) async throws
    func declineFriendRequest(currentUserId: String, requesterId: String) async throws
    func removeFriend(currentUserId: String, targetUserId: String) async throws
    func isFriend(currentUserId: String, targetUserId: String) async throws -> Bool
    func hasSentRequest(fromUserId: String, toUserId: String) async throws -> Bool
    func hasReceivedRequest(currentUserId: String, fromUserId: String) async throws -> Bool
    func getFriendStatus(currentUserId: String, targetUserId: String) async throws -> FriendStatus
    func fetchFriends(userId: String) async throws -> [String]
    func fetchPendingFriendsRequests(userId: String) async throws -> [String]
    func fetchPendingHostsRequests(userId: String) async throws -> [String]

    func listenPendingFriendsRequestsCount(userId: String, onChange: @escaping (Int) -> Void) -> RealtimeListenerHandle

    func listenPendingHostsRequestsCount(userId: String, onChange: @escaping (Int) -> Void) -> RealtimeListenerHandle

    func listenFriendStatus(currentUserId: String, targetUserId: String, onChange: @escaping (FriendStatus) -> Void) -> RealtimeListenerHandle
}

extension IFriendRepository {
    
    func listenPendingFriendsRequestsCount(userId: String, onChange: @escaping (Int) -> Void) -> RealtimeListenerHandle {
        NoOpListenerHandle()
    }

    func listenPendingHostsRequestsCount(userId: String, onChange: @escaping (Int) -> Void) -> RealtimeListenerHandle {
        NoOpListenerHandle()
    }

    func listenFriendStatus(currentUserId: String, targetUserId: String, onChange: @escaping (FriendStatus) -> Void) -> RealtimeListenerHandle {
        NoOpListenerHandle()
    }
}

extension FriendRepository: IFriendRepository {}
