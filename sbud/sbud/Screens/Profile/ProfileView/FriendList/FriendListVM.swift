//
//  FriendListVM.swift
//  sbud
//
//  Created by Erdal on 29.04.2026.
//

import Foundation
import Combine

@MainActor
final class FriendListVM: ObservableObject {
    @Published var users: [UserProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let friendManager = FriendManager.shared
    private let userRepository = UserRepository()
    let userId: String

    init(userId: String) {
        self.userId = userId
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let ids = try await friendManager.fetchFriends(userId: userId)
            var profiles: [UserProfile] = []
            for id in ids {
                if let profile = try await userRepository.fetchProfile(id) {
                    profiles.append(profile)
                }
            }
            users = profiles
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
