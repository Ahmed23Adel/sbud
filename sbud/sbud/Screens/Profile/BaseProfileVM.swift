//
//  BaseProfileVM.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import Combine
import FirebaseAuth

/// Holds state and logic that is identical for both own-profile and other-profile flows.
/// Never instantiated directly — use OwnProfileVM or OtherProfileVM.
@MainActor
class BaseProfileVM: ObservableObject {

    // MARK: - Shared published state

    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies (shared)

    let userId: String
    let profileManager = ProfileManager.shared
    let userRepository = UserRepository()

    // MARK: - Init

    init(userId: String) {
        self.userId = userId
    }

    // MARK: - Shared loading logic

    /// Fetches the profile from the network and updates `profile`.
    /// Subclasses call this inside their own `load()` and then do their extra work.
    func loadProfile() async {
        // Show cached own-profile immediately if available
        if let local = profileManager.getLocalProfile(), local.id == userId {
            profile = local
        }

        isLoading = profile == nil
        defer { isLoading = false }

        do {
            if let fresh = try await userRepository.fetchProfile(userId) {
                profile = fresh
            }
        } catch {
            if profile == nil { errorMessage = error.localizedDescription }
        }
    }
}
