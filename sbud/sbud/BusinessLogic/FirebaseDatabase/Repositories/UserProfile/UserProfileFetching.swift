//
//  UserProfileFetching.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import Foundation

protocol UserProfileFetching {
    func fetchProfile(_ id: String) async throws -> UserProfile?

    func listenProfile(_ id: String, onChange: @escaping (UserProfile?) -> Void) -> RealtimeListenerHandle
}

extension UserProfileFetching {
    func listenProfile(_ id: String, onChange: @escaping (UserProfile?) -> Void) -> RealtimeListenerHandle {
        NoOpListenerHandle()
    }
}

extension UserRepository: UserProfileFetching {}
