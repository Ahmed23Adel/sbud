//
//  UserCardVM.swift
//  sbud
//
//  Created by Erdal on 14.04.2026.
//

import Foundation
import Combine

@MainActor
final class UserCardVM: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchUser(userId: String) async {
        guard !userId.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            userProfile = try await ProfileManager.shared.getProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

//    func displayName(fallback: String) -> String {
//        if let profile = userProfile,
//           !profile.name.isEmpty {
//            return "\(profile.name) \(profile.surName)".trimmingCharacters(in: .whitespaces)
//        }
//        return fallback
//    }
    
    func displayName(fallback: String) -> String {
        if let profile = userProfile,
           !profile.name.isEmpty {
            let lastInitial = profile.surName.first.map { "\($0)." } ?? ""
            return "\(profile.name) \(lastInitial)".trimmingCharacters(in: .whitespaces)
        }
        return fallback
    }

    var targetDistance: String? {
        return nil  // TODO: add
    }

    var pace: String? {
        guard let p = userProfile?.metrics.averagePace, !p.isEmpty else { return nil }
        return "\(p)/KM"
    }
}
