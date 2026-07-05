//
//  OwnProfileVM.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import Combine
import FirebaseAnalytics

@MainActor
final class OwnProfileVM: BaseProfileVM {

    @Published var pendingFriendsRequestCount: Int = 0
    @Published var pendingHostsRequestCount: Int = 0

    private let friendManager: FriendManager
    private let currentUserProvider: CurrentUserProviding

    init(
        userId: String,
        userRepository: UserProfileFetching = UserRepository(),
        friendManager: FriendManager = FriendManager.shared,
        currentUserProvider: CurrentUserProviding = FirebaseCurrentUserProvider()
    ) {
        self.friendManager = friendManager
        self.currentUserProvider = currentUserProvider
        super.init(userId: userId, userRepository: userRepository)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "OwnProfile"])
    }

    func load() async {
        await loadProfile()
        if let profile { profileManager.saveProfileToLocale(profile: profile) }
        await loadPendingFriendsRequests()
        await loadPendingHostRequests()
    }

    private func loadPendingFriendsRequests() async {
        guard let uid = currentUserProvider.currentUserId else { return }
        let ids = (try? await friendManager.fetchFriendsPendingRequests(userId: uid)) ?? []
        pendingFriendsRequestCount = ids.count
    }

    private func loadPendingHostRequests() async {
        guard let uid = currentUserProvider.currentUserId else { return }
        let ids = (try? await friendManager.fetchHostsPendingRequests(userId: uid)) ?? []
        pendingHostsRequestCount = ids.count
    }
}
