//
//  ViewModelHosts.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation

@Observable
class ViewModelHosts{
    var eventId: String
    var isLoading = false
    var userId: String
    
    private let friendManager = FriendManager.shared
    private let userRepository = UserRepository()
    
    
    var friendsProfiles: [UserProfile] = []
    init(eventId: String, userId: String) {
        self.eventId = eventId
        self.userId = userId
    }
    
    
    func loadFriends() async {
        // i need pic, name, userid
        isLoading = true
        defer { isLoading = false }
        do {
            let ids = try await friendManager.fetchFriends(userId: userId)
            var profiles: [UserProfile] = []
            for id in ids {
                if let profile = try await userRepository.fetchProfile(id) {
                    profiles.append(profile)
                }
            }
            friendsProfiles = profiles
        } catch {
        }
    }
}
