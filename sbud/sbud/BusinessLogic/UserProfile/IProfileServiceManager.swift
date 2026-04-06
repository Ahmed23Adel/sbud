//
//  IProfileManager.swift
//  sbud
//
//  Created by Erdal on 5.01.2026.
//

protocol IProfileServiceManager {
    var isProfileSetupComplete: Bool { get }

    func saveProfileToDatabase(profile: UserProfile) async throws
    func deleteProfileFromDatabase(uid: String) async throws
    func saveProfileToLocale(profile: UserProfile)
    func deleteProfileFromLocale()
    func syncProfileAfterLogin() async throws
}
