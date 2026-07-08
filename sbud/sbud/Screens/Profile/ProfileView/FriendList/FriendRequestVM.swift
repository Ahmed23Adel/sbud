//
//  FriendRequestVM.swift
//  sbud
//
//  Created by Erdal on 28.04.2026.
//

import Foundation
import Combine

@MainActor
final class FriendRequestsVM: ObservableObject {
    @Published var requests: [UserProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let friendManager: FriendManager
    private let userRepository: UserProfileFetching
    private let currentUserProvider: CurrentUserProviding

    init(
        friendManager: FriendManager = FriendManager.shared,
        userRepository: UserProfileFetching = UserRepository(),
        currentUserProvider: CurrentUserProviding = FirebaseCurrentUserProvider()
    ) {
        self.friendManager = friendManager
        self.userRepository = userRepository
        self.currentUserProvider = currentUserProvider
    }

    func load() async {
        guard let uid = currentUserProvider.currentUserId else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let ids = try await friendManager.fetchFriendsPendingRequests(userId: uid)
            var profiles: [UserProfile] = []
            for id in ids {
                if let profile = try await userRepository.fetchProfile(id) {
                    profiles.append(profile)
                }
            }
            requests = profiles
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func accept(_ user: UserProfile) async {
        do {
            try await friendManager.acceptRequest(requesterId: user.id)
            requests.removeAll { $0.id == user.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func decline(_ user: UserProfile) async {
        do {
            try await friendManager.declineRequest(requesterId: user.id)
            requests.removeAll { $0.id == user.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
