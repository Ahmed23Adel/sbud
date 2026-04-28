//
//  SettingsVM.swift
//  sbud
//
//  Created by Erdal on 28.04.2026.
//

import SwiftUI
import Combine

@MainActor
final class SettingsVM: ObservableObject {
    @Published var isPrivate: Bool = false
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let profileManager = ProfileManager.shared
    private let userRepository = UserRepository()

    init() {
        isPrivate = profileManager.getLocalProfile()?.isPrivate ?? false
    }

    func togglePrivacy() async {
        isSaving = true
        defer { isSaving = false }

        let newValue = !isPrivate
        do {
            guard var profile = profileManager.getLocalProfile() else { return }
            try await userRepository.updateUserProfileFields(
                uid: profile.id,
                fields: ["isPrivate": newValue]
            )
            profile.isPrivate = newValue
            profileManager.saveProfileToLocale(profile: profile)
            isPrivate = newValue
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


