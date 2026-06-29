//
//  SettingsVM.swift
//  sbud
//
//  Created by Erdal on 28.04.2026.
//
import Foundation
import FirebaseAuth
import Combine
import FirebaseAnalytics

@MainActor
final class SettingsVM: ObservableObject {
    @Published var isPrivate: Bool = false
    @Published var showEmail: Bool = false
    @Published var showPhone: Bool = false
    @Published var showAddress: Bool = false

    @Published var isSaving = false

    private let profileManager = ProfileManager.shared

    init() {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "Settings"])
    }

    func loadFromLocal() {
        guard let local = profileManager.getLocalProfile() else { return }
        isPrivate   = local.isPrivate
        showEmail   = local.showEmail
        showPhone   = local.showPhone
        showAddress = local.showAddress
    }

    func savePrivacySettings() async {
        guard let uid = Auth.auth().currentUser?.uid,
              var local = profileManager.getLocalProfile() else { return }

        isSaving = true
        defer { isSaving = false }


        local.isPrivate   = isPrivate
        local.showEmail   = showEmail
        local.showPhone   = showPhone

        let fields: [String: Any] = [
            "isPrivate":   isPrivate,
            "showEmail":   showEmail,
            "showPhone":   showPhone
        ]

        do {
            try await profileManager.updateProfileStep(uid: uid, fields: fields, localProfile: local)
        } catch {
            print("Privacy update error:", error.localizedDescription)
        }
    }
}
