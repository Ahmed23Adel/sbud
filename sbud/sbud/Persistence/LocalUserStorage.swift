//
//  LocalUserStorage.swift
//  sbud
//
//  Created by Erdal on 27/12/2025.
//
import Foundation

final class LocalUserStorage {

    private let profileKey = "local_user_profile"

    func save(_ profile: UserProfile) {
        do {
            let data = try JSONEncoder().encode(profile)
            UserDefaults.standard.set(data, forKey: profileKey)
        } catch {
            print("LocalUserStorage save error:", error)
        }
    }

    func load() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(UserProfile.self, from: data)
        } catch {
            print("LocalUserStorage load error:", error)
            return nil
        }
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: profileKey)
    }
}

