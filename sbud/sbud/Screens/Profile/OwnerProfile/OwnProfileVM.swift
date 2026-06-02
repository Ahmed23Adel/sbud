//
//  OwnProfileVM.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import FirebaseAuth
import Combine
import FirebaseAnalytics

@MainActor
final class OwnProfileVM: BaseProfileVM {

    // MARK: - Own-profile-only state

    @Published var pendingFriendsRequestCount: Int = 0
    @Published var pendingHostsRequestCount: Int = 0

    // MARK: - Dependencies

    private let friendManager = FriendManager.shared

    // MARK: - Init

    override init(userId: String) {
        super.init(userId: userId)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "OwnProfile"])
    }

    // MARK: - Load

    func load() async {
        await loadProfile()

        // Persist fresh profile locally so other screens get the cache
        if let profile {
            profileManager.saveProfileToLocale(profile: profile)
        }

        await loadPendingFriendsRequests()
        await loadPendingHostRequests()
    }

    // MARK: - Private

    private func loadPendingFriendsRequests() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ids = (try? await friendManager.fetchFriendsPendingRequests(userId: uid)) ?? []
        pendingFriendsRequestCount = ids.count
    }
    
    
    private func loadPendingHostRequests() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ids = (try? await friendManager.fetchHostsPendingRequests(userId: uid)) ?? []
        pendingHostsRequestCount = ids.count
    }
}
