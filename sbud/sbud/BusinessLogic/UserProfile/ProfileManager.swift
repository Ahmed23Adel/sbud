//
//  ProfileManager.swift
//  sbud
//
//  Created by Erdal on 5.01.2026.
//

/*import Foundation
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
    
    func updateProfileStep(uid: String, fields: [String: Any]) async throws {
            try await userRepository.updateUserProfileFields(uid: uid, fields: fields)
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
}*/

import Foundation
import FirebaseAuth
import FirebaseStorage

class ProfileManager: IProfileServiceManager {
    
    static let shared = ProfileManager()
    
    private let localStorage = LocalUserStorage()
    private let authManager = AuthenticationManager.shared
    private let userRepository = UserRepository()
    
    private init() {}

    var isProfileSetupComplete: Bool {
        guard let profile = localStorage.load() else { return false }
        return profile.isProfileCompleted
    }

    func getLocalProfile() -> UserProfile? {
        localStorage.load()
    }

    func syncProfileAfterLogin() async throws {
        guard let uid = authManager.currentUser?.uid else { return }

        if let remoteProfile = try await userRepository.fetchProfile(uid) {
            print("8")
            localStorage.save(remoteProfile)
        } else {
            print("9")
            let newProfile = UserProfile(id: uid)
            localStorage.save(newProfile)
            print("burada1.")
        }
    }
    
    func saveProfileToDatabase(profile: UserProfile) async throws {
        if let errorMessage = try await userRepository.save(profile) {
            throw NSError(
                domain: "UserRepositoryError",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            )
        }
    }

    func updateProfileStep(uid: String, fields: [String: Any], localProfile: UserProfile) async throws {
        try await userRepository.updateUserProfileFields(uid: uid, fields: fields)
        localStorage.save(localProfile)
    }
    
    func uploadProfileImage(data: Data, userId: String) async throws -> String {
            let ref = Storage.storage().reference().child("profile_images/\(userId).jpg")

            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            _ = try await ref.putDataAsync(data, metadata: metadata)
            let downloadURL = try await ref.downloadURL()
            return downloadURL.absoluteString
        }

    func saveProfileToLocale(profile: UserProfile) {    localStorage.save(profile)  }
    func deleteProfileFromLocale() { localStorage.clear() }
    func deleteProfileFromDatabase(uid: String) async throws {
    }
}
