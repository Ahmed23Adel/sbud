//
//  ViewModelHosts.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import OSLog
import FirebaseAnalytics


@Observable
class ViewModelHosts{
    var eventId: String
    var isLoading = false
    var userId: String
    
    private let friendManager = FriendManager.shared
    private let userRepository = UserRepository()
    private let hostRepo: HostsRepository
    
    var friendsProfiles: [UserProfile] = []
    var hostsInvitations: [HostInvitation] = []
    var friendHostItems: [FriendHostItem] = []
    
    var alertMsg = ""
    var isShowAlert = false
    
    let logger = Logger(subsystem: "sbud", category: "ViewModelHosts")
    init(eventId: String, userId: String) {
        logger.info("eventid: \(eventId) for userId: \(userId)")
        self.eventId = eventId
        self.userId = userId
        hostRepo = HostsRepository(eventId: eventId)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "ManageHosts",
            "event_id": eventId
        ])
        Task{
            await loadHostsInvitationsAndFriendAndCombine()
        }
        
    }
    
    
    private func loadHostsInvitationsAndFriendAndCombine() async {
        do {
            try await  loadFriends()
            logger.info("friends count \(self.friendsProfiles.count)")
            try await loadHostsInvitations()
            logger.info("hosts count: \(self.hostsInvitations.count)")
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
    
    func inviteHost(item: FriendHostItem) async {
        let invitation = HostInvitation(
            invitedAt: Date(),
            status: .pending,
            userId: item.profile.id,
        )
        do {
            try await hostRepo.inviteHost(invitation)
            updateLocalState(for: item.id, to: .pending)
            logger.info("Invited \(invitation.userId) ")
        } catch {
            logger.error("inviteHost failed: \(error)")
            showError("Failed to send invitation. Please try again.")
        }
    }

    func cancelInvitation(item: FriendHostItem) async {
        do {
            try await hostRepo.removeInvitation(targetUserId: item.id)
            updateLocalState(for: item.id, to: nil)
        } catch {
            logger.error("cancelInvitation failed: \(error)")
            showError("Failed to cancel invitation. Please try again.")
        }
    }

    func removeHost(item: FriendHostItem) async {
        do {
            try await hostRepo.removeInvitation(targetUserId: item.id)
            updateLocalState(for: item.id, to: nil)
        } catch {
            logger.error("removeHost failed: \(error)")
            showError("Failed to remove host. Please try again.")
        }
    }

    func reInviteHost(item: FriendHostItem) async {
        // remove the declined doc first, then write a fresh pending one
        do {
            try await hostRepo.removeInvitation(targetUserId: item.id)
            let invitation = HostInvitation(
                invitedAt: Date(),
                status: .pending,
                userId: item.id,
            )
            try await hostRepo.inviteHost(invitation)
            updateLocalState(for: item.id, to: .pending)
        } catch {
            logger.error("reInviteHost failed: \(error)")
            showError("Failed to re-send invitation. Please try again.")
        }
    }
    
    private func showError(_ message: String) {
        alertMsg = message
        isShowAlert = true
    }
    
    private func updateLocalState(for userId: String, to newStatus: HostInvitationStatus?) {
        guard let index = friendHostItems.firstIndex(where: { $0.id == userId }) else { return }
        let profile = friendHostItems[index].profile

        let newInvitation: HostInvitation? = newStatus.map {
            HostInvitation(invitedAt: Date(), status: $0, userId: userId)
        }

        friendHostItems[index] = FriendHostItem(
            id: userId,
            profile: profile,
            invitation: newInvitation
        )
    }
}


