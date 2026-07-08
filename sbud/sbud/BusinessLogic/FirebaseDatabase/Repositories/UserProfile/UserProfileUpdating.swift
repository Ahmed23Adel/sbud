//
//  UserProfileUpdating.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import Foundation
protocol UserProfileUpdating {
    func updateUserProfileFields(uid: String, fields: [String: Any]) async throws
}
extension UserRepository: UserProfileUpdating {}
