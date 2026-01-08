//
//  ProfileSetupVM.swift
//  sbud
//
//  Created by Erdal on 23/12/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class ProfileSetupVM: ObservableObject {

    
    @Published var profile: UserProfile
    private let profileManager: ProfileManager
    @Published var isSaving = false
    @Published var errorMessage: String?
    

        let genderOptions = ["Male", "Female", "Other", "Prefer not to say"]
 
    init(profileManager: ProfileManager = .shared) {
            self.profileManager = profileManager
            let uid = Auth.auth().currentUser?.uid ?? ""
            self.profile = UserProfile(id: uid)
        }
    
    func save() async -> Bool {
            do {
                try await profileManager.saveProfileToDatabase(profile: self.profile)
                profileManager.saveProfileToLocale(profile: self.profile)
                print("Profil hem buluta hem yerele başarıyla kaydedildi.")
                return true
            } catch {
                print("Hata: \(error.localizedDescription)")
                return false
            }
        }
    
    /*private func buildMetricsModel() -> ActivityMetrics {
        return ActivityMetrics(
            averagePace: averagePace.isEmpty ? nil : averagePace,
            averageSpeed: Double(averageSpeed) ?? nil,
            goalsPerMatch: Int(goalsPerMatch) ?? nil
        )
    }*/
}
