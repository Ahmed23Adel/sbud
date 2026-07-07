//
//  IProfileManager.swift
//  sbud
//
//  Created by Erdal on 5.01.2026.
//

import Foundation

protocol IProfileServiceManager {
    var isProfileSetupComplete: Bool { get }
    func getLocalProfile() -> UserProfile?
    func saveProfileToDatabase(profile: UserProfile) async throws
    func deleteProfileFromDatabase(uid: String) async throws
    func saveProfileToLocale(profile: UserProfile)
    func deleteProfileFromLocale()
    func syncProfileAfterLogin() async throws
    func updateProfileStep(uid: String, fields: [String: Any], localProfile: UserProfile) async throws
    func uploadProfileImage(data: Data) async throws -> String
}
