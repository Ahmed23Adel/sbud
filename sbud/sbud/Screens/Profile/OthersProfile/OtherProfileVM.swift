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

    @Published var friendStatus: FriendStatus = .notFriend
    @Published var isFriendActionLoading = false

    var isFriend: Bool          { friendStatus == .friends }
    var isRequestSent: Bool     { friendStatus == .requestSent }
    var isRequestReceived: Bool { friendStatus == .requestReceived }

    private let friendManager: FriendManager

    init(
        userId: String,
        userRepository: UserProfileFetching = UserRepository(),
        friendManager: FriendManager = FriendManager.shared
    ) {
        self.friendManager = friendManager
        super.init(userId: userId, userRepository: userRepository)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "OtherProfile",
            "viewed_user_id": userId
        ])
    }

    func load() async {
        await loadProfile()
        await refreshFriendStatus()
    }

    func refreshFriendStatus() async {
        do {
            friendStatus = try await friendManager.getFriendStatus(targetUserId: userId)
        } catch {
            print("refreshFriendStatus error:", error)
        }
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
