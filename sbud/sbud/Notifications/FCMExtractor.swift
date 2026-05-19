//
//  FCMExtractor.swift
//  sbud
//
//  Created by ahmed on 03/05/2026.
//

import Foundation
import FirebaseMessaging
import FirebaseFirestore

struct FCMExtractor{
    
    func saveFCMToken() async {
        do {
            let token = try await Messaging.messaging().token()
            let userId = ProfileManager.shared.getLocalProfile()!.id
            let userRepo = UserRepository()
            try await userRepo.updateUserProfileFields(uid: userId, fields: ["fcmToken": token])
        } catch {
            print("Failed to save FCM token: \(error)")
        }
    }
}
