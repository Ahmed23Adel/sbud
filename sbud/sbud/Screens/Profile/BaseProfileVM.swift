//
//  BaseProfileVM.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import Combine

@MainActor
class BaseProfileVM: ObservableObject {

    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let userId: String
    let profileManager = ProfileManager.shared
    let userRepository: UserProfileFetching

    init(userId: String, userRepository: UserProfileFetching = UserRepository()) {
        self.userId = userId
        self.userRepository = userRepository
    }

    func loadProfile() async {
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
