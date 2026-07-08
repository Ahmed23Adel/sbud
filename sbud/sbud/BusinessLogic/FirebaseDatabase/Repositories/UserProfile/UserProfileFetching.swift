//
//  UserProfileFetching.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import Foundation
protocol UserProfileFetching {
    func fetchProfile(_ id: String) async throws -> UserProfile?
}
extension UserRepository: UserProfileFetching {}
