//
//  FollowListVM.swift
//  sbud
//
//  Created by Erdal on 28.04.2026.
//

import Foundation
import Combine

enum FollowListMode {
    case followers
    case following

    var title: String {
        switch self {
        case .followers: return "FOLLOWERS"
        case .following: return "FOLLOWING"
        }
    }
}

@MainActor
final class FollowListVM: ObservableObject {
    @Published var users: [UserProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let followManager = FollowManager.shared
    private let userRepository = UserRepository()
    let userId: String
    let mode: FollowListMode

    init(userId: String, mode: FollowListMode) {
        self.userId = userId
        self.mode = mode
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let ids: [String]
            switch mode {
            case .followers: ids = try await followManager.fetchFollowers(userId: userId)
            case .following: ids = try await followManager.fetchFollowing(userId: userId)
            }

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
