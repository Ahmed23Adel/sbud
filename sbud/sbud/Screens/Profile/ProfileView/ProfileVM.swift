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
    @Published var friendStatus: FriendStatus = .notFriend
    @Published var isFriendActionLoading = false
    @Published var errorMessage: String?
    @Published var pendingRequestCount: Int = 0

    private let profileManager = ProfileManager.shared
    private let friendManager = FriendManager.shared
    private let userRepository = UserRepository()
    let userId: String

    var isOwnProfile: Bool { userId == Auth.auth().currentUser?.uid }

    var displayName: String {
        guard let p = profile else { return "" }
        let last = p.surName.first.map { "\($0)." } ?? ""
        return "\(p.name.uppercased()) \(last.uppercased())"
            .trimmingCharacters(in: .init(charactersIn: "_"))
    }

    var isFriend: Bool          { friendStatus == .friends         }
    var isRequestSent: Bool     { friendStatus == .requestSent     }
    var isRequestReceived: Bool { friendStatus == .requestReceived }

    init(userId: String) {
        self.userId = userId
    }

    func load() async {
        if isOwnProfile, let local = profileManager.getLocalProfile() {
            profile = local
        }
        isLoading = profile == nil
        defer { isLoading = false }

        do {
            if let fresh = try await userRepository.fetchProfile(userId) {
                profile = fresh
                if isOwnProfile { profileManager.saveProfileToLocale(profile: fresh) }
            }
        } catch {
            if profile == nil { errorMessage = error.localizedDescription }
        }

        if !isOwnProfile {
            await refreshFriendStatus()
        } else {
            if let uid = Auth.auth().currentUser?.uid {
                let ids = (try? await friendManager.fetchPendingRequests(userId: uid)) ?? []
                pendingRequestCount = ids.count
            }
        }
    }

    func refreshFriendStatus() async {
        do {
            friendStatus = try await friendManager.getFriendStatus(targetUserId: userId)
        } catch {
            print("refreshFriendStatus error:", error)
        }
    }

    func applyUpdatedProfile(_ updated: UserProfile) {
        profile = updated
    }

    func toggleFriendAction() async {
        guard !isFriendActionLoading else { return }
        isFriendActionLoading = true
        defer { isFriendActionLoading = false }

        do {
            switch friendStatus {
            case .notFriend:
                let isPrivate = profile?.isPrivate ?? false
                try await friendManager.addFriend(targetUserId: userId, isTargetPrivate: isPrivate)
                friendStatus = isPrivate ? .requestSent : .friends
                if !isPrivate { profile?.friendsCount = (profile?.friendsCount ?? 0) + 1 }

            case .requestSent:
                try await friendManager.cancelRequest(targetUserId: userId)
                friendStatus = .notFriend

            case .requestReceived:
                try await friendManager.acceptRequest(requesterId: userId)
                friendStatus = .friends
                profile?.friendsCount = (profile?.friendsCount ?? 0) + 1

            case .friends:
                try await friendManager.removeFriend(targetUserId: userId)
                friendStatus = .notFriend
                profile?.friendsCount = max(0, (profile?.friendsCount ?? 1) - 1)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
