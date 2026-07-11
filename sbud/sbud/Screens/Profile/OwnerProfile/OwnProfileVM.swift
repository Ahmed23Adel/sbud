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
    @Published var statsLoaded: Bool = false

    private let friendManager: FriendManager
    private let currentUserProvider: CurrentUserProviding
    private let statsRequester: UserStatsRequester

    // MARK: - Real-time listener handles

    private var friendsRequestsListener: RealtimeListenerHandle?
    private var hostsRequestsListener: RealtimeListenerHandle?
    private var profileListener: RealtimeListenerHandle?

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
       
        startRealtimeListening()

       
        await loadProfile()

       
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadStats() }
        }

        if let profile { profileManager.saveProfileToLocale(profile: profile) }
    }

    // MARK: - Real-time listening lifecycle

    func startRealtimeListening() {
        guard let uid = currentUserProvider.currentUserId else { return }

        guard friendsRequestsListener == nil else { return }

        friendsRequestsListener = friendManager.listenPendingFriendsRequestsCount(userId: uid) { [weak self] count in
            Task { @MainActor in self?.pendingFriendsRequestCount = count }
        }

        hostsRequestsListener = friendManager.listenPendingHostsRequestsCount(userId: uid) { [weak self] count in
            Task { @MainActor in self?.pendingHostsRequestCount = count }
        }

        profileListener = userRepository.listenProfile(userId) { [weak self] updatedProfile in
            guard let self, let updatedProfile else { return }
            Task { @MainActor in
                self.profile?.friendsCount = updatedProfile.friendsCount
            }
        }
    }

    func stopRealtimeListening() {
        friendsRequestsListener?.remove()
        hostsRequestsListener?.remove()
        profileListener?.remove()
        friendsRequestsListener = nil
        hostsRequestsListener = nil
        profileListener = nil
    }

    // MARK: - Stats

    private func loadStats() async {
        guard !userId.isEmpty else {
            statsLoaded = true
            return
        }
        do {
            let stats = try await statsRequester.fetchStats(userId: userId)
            profile?.applyStats(stats)
        } catch {
            
        }
        statsLoaded = true
    }
}

