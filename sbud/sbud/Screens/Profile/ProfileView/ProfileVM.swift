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
    @Published var isFollowing = false
    @Published var isFollowLoading = false
    @Published var errorMessage: String?

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
        return "\(p.name.uppercased())_\(last.uppercased())"
            .trimmingCharacters(in: .init(charactersIn: "_"))
    }

    init(userId: String) {
        self.userId = userId
    }

    func load() async {
        print("load called — userId:", userId)
        print("isOwnProfile:", isOwnProfile)

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
            print("checking follow status...")
            await checkFollowStatus()
        }
    }

    private func checkFollowStatus() async {
        do {
            isFollowing = try await followManager.isFollowing(targetUserId: userId)
            print("checkFollowStatus result:", isFollowing)
        } catch {
            print("checkFollowStatus error:", error)
        }
    }

    // MARK: - Follow / Unfollow
    func toggleFollow() async {
        guard !isFollowLoading else { return }
        isFollowLoading = true
        defer { isFollowLoading = false }

        do {
            if isFollowing {
                try await followManager.unfollow(targetUserId: userId)
                isFollowing = false
                profile?.followersCount -= 1
            } else {
                try await followManager.follow(targetUserId: userId)
                isFollowing = true
                profile?.followersCount += 1
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

