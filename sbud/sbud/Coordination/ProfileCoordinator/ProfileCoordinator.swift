//
//  ProfileCoordinator.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

//  Manages navigation within the Profile tab.
//  Communicates upward via AuthCoordinatorDelegate — no MainCoordinator reference.
//  No Firebase imports. No silent navigation failures.
//

import Foundation
import OSLog
import Combine
@MainActor
final class ProfileCoordinator: ObservableObject {

    // MARK: - Published State

    @Published private(set) var rootRoute: ProfileRoute
    @Published var navigationPath: [ProfileRoutePushed] = []
    @Published var activeSheet: ProfileSheetType?
    @Published private(set) var userId: String
    var onPush: ((ProfileRoutePushed) -> Void)?
    
    // MARK: - Dependencies

    /// Weak reference — MainCoordinator conforms to this.
    weak var delegate: AuthCoordinatorDelegate?

    private let currentUserId: String
    private let logger = Logger(subsystem: "sbud", category: "ProfileCoordinator")

    // MARK: - Init

    init(userId: String, currentUserId: String) {
        self.userId = userId
        self.currentUserId = currentUserId
        self.rootRoute = userId == currentUserId ? .myProfile : .othersProfile
    }

    // MARK: - Computed

    var isViewingOwnProfile: Bool {
        userId == currentUserId
    }

    // MARK: - Push Navigation

    private func push(_ route: ProfileRoutePushed) {
        if let onPush {
            // Embedded — delegate the push to the parent stack.
            onPush(route)
        } else {
            // Tab root — owns its own NavigationStack.
            navigationPath.append(route)
        }
    }
    
    func goToOthersEvents() {
        push(.othersEvents(userId: userId))  // carries the correct userId
    }

    func goToMyEvents() {
        push(.myEvents(userId: userId))
    }

    func goToFriendsList() {
        push(.friendsList(userId: userId))
    }

    func goToAppropriateEvents() {
        push(isViewingOwnProfile ? .myEvents(userId: userId) : .othersEvents(userId: userId))
    }
    func goToSettings() {
        guard rootRoute == .myProfile else { return }
        push(.settings)
    }

    func goToFriendRequests() {
        guard rootRoute == .myProfile else { return }
        push(.friendRequests)
    }

    func goToHostRequests() {
        guard rootRoute == .myProfile else { return }
        push(.hostRequests)
    }

    func goToMyEventDetails(eventId: String) {
        push(.myEventDetails(eventId: eventId))
    }

    func goToOthersEventDetails(eventId: String) {
        push(.othersEventDetails(eventId: eventId))
    }

    func goToOthersProfile(userId: String) {
        push(.othersProfile(userId: userId))
    }

    func goToEventConversations(eventId: String, eventTitle: String) {
        push(.eventConversations(eventId: eventId, eventTitle: eventTitle))
    }

    func goToEventChat(partnerId: String, partnerName: String, partnerImageUrl: String?, eventId: String, eventTitle: String) {
        push(.eventChat(partnerId: partnerId, partnerName: partnerName, partnerImageUrl: partnerImageUrl, eventId: eventId, eventTitle: eventTitle))
    }
    
    func goToSessionSummary(evnet: EventFullDetails) {
        push(.sessionSummary(event: evnet))
    }

    func goToScannedProfile(userId: String) {
        guard !userId.isEmpty else { return }
        activeSheet = nil
        push(.scannedProfile(userId: userId))
    }

    // MARK: - Sheets

    func showHostsSheet(eventId: String) {
        activeSheet = .hosts(eventId: eventId)
    }

    func showQRCode() {
        activeSheet = .qrCode
    }

    func dismissSheet() {
        activeSheet = nil
    }

    // MARK: - Root Switch (e.g. after scanning a new user)

    func switchToProfile(userId: String) {
        self.userId = userId
        navigationPath = []
        rootRoute = userId == currentUserId ? .myProfile : .othersProfile
    }

    // MARK: - Delegate Actions (bubble up to MainCoordinator)

    func requestLogout() {
        delegate?.coordinatorDidRequestLogout()
    }
}
