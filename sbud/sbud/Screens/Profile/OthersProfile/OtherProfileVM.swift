//
//  OtherProfileVM.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import Combine
import FirebaseAnalytics

@MainActor
final class OtherProfileVM: BaseProfileVM {

    // MARK: - Other-profile-only state

    @Published var friendStatus: FriendStatus = .notFriend
    @Published var isFriendActionLoading = false

    // MARK: - Convenience

    var isFriend: Bool          { friendStatus == .friends         }
    var isRequestSent: Bool     { friendStatus == .requestSent     }
    var isRequestReceived: Bool { friendStatus == .requestReceived }

    // MARK: - Dependencies

    private let friendManager = FriendManager.shared

    // MARK: - Init

    override init(userId: String) {
        super.init(userId: userId)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "OtherProfile",
            "viewed_user_id": userId
        ])
    }

    // MARK: - Load

    func load() async {
        await loadProfile()
        await refreshFriendStatus()
    }

    // MARK: - Friend status

    func refreshFriendStatus() async {
        do {
            friendStatus = try await friendManager.getFriendStatus(targetUserId: userId)
        } catch {
            print("refreshFriendStatus error:", error)
        }
    }

    // MARK: - Friend actions

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
                if friendStatus == .friends {
                    profile?.friendsCount = (profile?.friendsCount ?? 0) + 1
                }

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
