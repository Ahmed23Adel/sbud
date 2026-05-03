//
//  OwnProfileVM.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class OwnProfileVM: BaseProfileVM {

    // MARK: - Own-profile-only state

    @Published var pendingRequestCount: Int = 0

    // MARK: - Dependencies

    private let friendManager = FriendManager.shared

    // MARK: - Load

    func load() async {
        await loadProfile()

        // Persist fresh profile locally so other screens get the cache
        if let profile {
            profileManager.saveProfileToLocale(profile: profile)
        }

        await loadPendingRequests()
    }

    // MARK: - Private

    private func loadPendingRequests() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ids = (try? await friendManager.fetchPendingRequests(userId: uid)) ?? []
        pendingRequestCount = ids.count
    }
}
