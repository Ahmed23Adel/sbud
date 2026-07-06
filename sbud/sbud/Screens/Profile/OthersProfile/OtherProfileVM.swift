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
    private let statsRequester: UserStatsRequester

    init(
        userId: String,
        userRepository: UserProfileFetching = UserRepository(),
        friendManager: FriendManager = FriendManager.shared,
        statsRequester: UserStatsRequester = UserStatsRequester()
    ) {
        self.friendManager = friendManager
        self.statsRequester = statsRequester
        super.init(userId: userId, userRepository: userRepository)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "OtherProfile",
            "viewed_user_id": userId
        ])
    }

    func load() async {
        // 1. Önce profili yükle — profile nil olmamalı stats apply edilmeden önce
        await loadProfile()

        // 2. Sonra paralel: stats + friend status
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadStats() }
            group.addTask { await self.refreshFriendStatus() }
        }
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

