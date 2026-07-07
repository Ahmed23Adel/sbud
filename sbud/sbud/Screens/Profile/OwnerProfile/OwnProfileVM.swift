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
    private let statsRequester: UserStatsRequester

    init(
        userId: String,
        userRepository: UserProfileFetching = UserRepository(),
        friendManager: FriendManager = FriendManager.shared,
        currentUserProvider: CurrentUserProviding = FirebaseCurrentUserProvider(),
        statsRequester: UserStatsRequester = UserStatsRequester()
    ) {
        self.friendManager = friendManager
        self.currentUserProvider = currentUserProvider
        self.statsRequester = statsRequester
        super.init(userId: userId, userRepository: userRepository)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "OwnProfile"])
    }

    func load() async {
        // 1. Önce profili yükle — profile nil olmamalı stats apply edilmeden önce
        await loadProfile()

        // 2. Sonra paralel: stats + badge counts
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadStats() }
            group.addTask { await self.loadPendingFriendsRequests() }
            group.addTask { await self.loadPendingHostRequests() }
        }

        if let profile { profileManager.saveProfileToLocale(profile: profile) }
    }

    // MARK: - Stats

    private func loadStats() async {
        do {
            let stats = try await statsRequester.fetchStats(userId: userId)
            profile?.applyStats(stats)
        } catch {
            // Stats yüklenemese bile profil gösterilmeye devam eder
        }
    }

    // MARK: - Pending counts

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
