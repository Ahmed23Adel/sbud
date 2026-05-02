//
//  ViewModelHosts.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import OSLog

@Observable
class ViewModelHosts{
    var eventId: String
    var isLoading = false
    var userId: String
    
    private let friendManager = FriendManager.shared
    private let userRepository = UserRepository()
    
    
    var friendsProfiles: [UserProfile] = []
    var hostsInvitations: [HostInvitation] = []
    var friendHostItems: [FriendHostItem] = []
    
    var alertMsg = ""
    var isShowAlert = false
    
    let logger = Logger(subsystem: "sbud", category: "ViewModelHosts")
    init(eventId: String, userId: String) {
        self.eventId = eventId
        self.userId = userId
        
        Task{
            await loadHostsInvitationsAndFriendAndCombine()
        }
        
    }
    
    
    private func loadHostsInvitationsAndFriendAndCombine() async {
        do {
            try await  loadFriends()
            try await loadHostsInvitations()
            logger.info("friends count \(self.friendsProfiles.count), hosts count: \(self.hostsInvitations.count)")
            combine()
            
        } catch {
            logger.fault("Error loading hosts: \(error)")
            showErrorWithLoadingHosts()
        }
    }
    
    
    
    func loadFriends() async throws {
        isLoading = true
        defer { isLoading = false }
        let ids = try await friendManager.fetchFriends(userId: userId)
        var profiles: [UserProfile] = []
        for id in ids {
            if let profile = try await userRepository.fetchProfile(id) {
                profiles.append(profile)
            }
        }
        friendsProfiles = profiles
    }
    
    func loadHostsInvitations() async throws {
        let repo = HostsRepository(eventId: eventId)
        let queryRef = repo.initQueryBuilderObject()
        hostsInvitations = try await repo.fetch(query: queryRef)
    }
    
    private func combine() {
        let inviteMap = Dictionary(uniqueKeysWithValues: hostsInvitations.map { ($0.userId, $0) })
        friendHostItems = friendsProfiles.map { profile in
            FriendHostItem(
                id: profile.id,
                profile: profile,
                invitation: inviteMap[profile.id]
            )
        }
    }
    
    private func showErrorWithLoadingHosts(){
        alertMsg = "Error with loading hosts information, please try again "
        isShowAlert = true
    }
}


