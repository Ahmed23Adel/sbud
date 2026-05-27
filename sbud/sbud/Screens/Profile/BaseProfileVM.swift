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

    func voteForFeedback(tag: String) async {
        guard let currentProfile = profile,
              let myUserId = Auth.auth().currentUser?.uid else { return }
        
        var currentVoters = currentProfile.feedbackVoters ?? [:]
        var tagVoters = currentVoters[tag] ?? []
        
        // Se hai già votato questo tag, ci fermiamo subito!
        if tagVoters.contains(myUserId) {
            return
        }
        
        // 1. Optimistic Update (UI Immediata)
        tagVoters.append(myUserId)
        currentVoters[tag] = tagVoters
        self.profile?.feedbackVoters = currentVoters
        
        // 2. Chiamata al server in background
        do {
            try await userRepository.addFeedback(for: userId, tag: tag, voterId: myUserId)
            
            if userId == profileManager.getLocalProfile()?.id, let savedProfile = self.profile {
                profileManager.saveProfileToLocale(profile: savedProfile)
            }
        } catch {
            print("Errore voto: \(error)")
            // Rollback se fallisce
            DispatchQueue.main.async {
                tagVoters.removeAll { $0 == myUserId }
                currentVoters[tag] = tagVoters
                self.profile?.feedbackVoters = currentVoters
            }
        }
    }
}
