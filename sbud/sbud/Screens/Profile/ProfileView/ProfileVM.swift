//
//  ProfileVM.swift
//  sbud
//
//  Created by Erdal on 27.04.2026.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class ProfileVM: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var followStatus: FollowStatus = .notFollowing
    @Published var isFollowLoading = false
    @Published var errorMessage: String?
    @Published var pendingRequestCount: Int = 0

    private let profileManager = ProfileManager.shared
    private let followManager = FollowManager.shared
    private let userRepository = UserRepository()
    let userId: String

    var isOwnProfile: Bool {
        userId == Auth.auth().currentUser?.uid
    }

    var displayName: String {
        guard let p = profile else { return "" }
        let last = p.surName.first.map { "\($0)." } ?? ""
        return "\(p.name.uppercased()) \(last.uppercased())"
            .trimmingCharacters(in: .init(charactersIn: "_"))
    }

    // MARK: - Computed helpers for View
    var isFollowing: Bool { followStatus == .following }
    var isPending: Bool   { followStatus == .pending   }

    init(userId: String) {
        self.userId = userId
    }

    // MARK: - Load
    func load() async {
        if isOwnProfile, let local = profileManager.getLocalProfile() {
            profile = local
        }

        isLoading = profile == nil
        defer { isLoading = false }

        do {
            if let fresh = try await userRepository.fetchProfile(userId) {
                profile = fresh
                if isOwnProfile {
                    profileManager.saveProfileToLocale(profile: fresh)
                }
            }
        } catch {
            if profile == nil { errorMessage = error.localizedDescription }
        }

        if !isOwnProfile {
            await refreshFollowStatus()
        } else {
            if let uid = Auth.auth().currentUser?.uid {
                let ids = (try? await followManager.fetchPendingRequests(userId: uid)) ?? []
                pendingRequestCount = ids.count
            }
        }
    }

    func refreshFollowStatus() async {
        do {
            followStatus = try await followManager.getFollowStatus(targetUserId: userId)
        } catch {
            print("refreshFollowStatus error:", error)
        }
    }

    // MARK: - Follow / Unfollow / Request
    func toggleFollow() async {
        guard !isFollowLoading else { return }
        isFollowLoading = true
        defer { isFollowLoading = false }

        do {
            switch followStatus {
            case .following:
                try await followManager.unfollow(targetUserId: userId)
                followStatus = .notFollowing
                profile?.followersCount = max(0, (profile?.followersCount ?? 1) - 1)

            case .pending:
                // Bekleyen isteği iptal et
                try await followManager.cancelRequest(targetUserId: userId)
                followStatus = .notFollowing

            case .notFollowing:
                let isPrivate = profile?.isPrivate ?? false
                try await followManager.follow(targetUserId: userId, isTargetPrivate: isPrivate)
                if isPrivate {
                    followStatus = .pending
                } else {
                    followStatus = .following
                    profile?.followersCount = (profile?.followersCount ?? 0) + 1
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

