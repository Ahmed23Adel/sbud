//
//  ProfileManager.swift
//  sbud
//
//  Created by Erdal on 5.01.2026.
//

import Foundation
import FirebaseAuth

class ProfileManager: IProfileServiceManager {
    
    static let shared = ProfileManager()
    
    private let localStorage = LocalUserStorage() 
    private let authManager = AuthenticationManager.shared
    private let userRepository = UserRepository()
    
    private init() {}

    // MARK: - Protokol Gereksinimleri
    var isProfileSetupComplete: Bool {
        return localStorage.load() != nil
    }
    
    func syncProfileAfterLogin() async throws {
        guard let uid = authManager.currentUser?.uid else { return }
        if localStorage.load() != nil { return  }

        if let remoteProfile = try await userRepository.fetchProfile(uid) {
            localStorage.save(remoteProfile)
        } else {
            print("Profile couldnot find.")
        }
    }
    
    func saveProfileToDatabase(profile: UserProfile) async throws {
        
        if let errorMessage = try await userRepository.save(profile) {
            throw NSError(domain: "UserRepositoryError",
                          code: 500,
                          userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
    }

    func saveProfileToLocale(profile: UserProfile) {    localStorage.save(profile)  }
    func deleteProfileFromLocale() { localStorage.clear() }
    func deleteProfileFromDatabase(uid: String) async throws {
    }
}
