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

    func goToSettings() {
        guard rootRoute == .myProfile else {
            logger.warning("goToSettings called from non-myProfile context — ignored")
            return
        }
        navigationPath.append(.settings)
    }

    func goToFriendRequests() {
        guard rootRoute == .myProfile else { return }
        navigationPath.append(.friendRequests)
    }

    func goToHostRequests() {
        guard rootRoute == .myProfile else { return }
        navigationPath.append(.hostRequests)
    }

    func goToMyEvents() {
        guard rootRoute == .myProfile else { return }
        navigationPath.append(.myEvents)
    }

    func goToOthersEvents() {
        print(rootRoute, rootRoute == .othersProfile)
        guard rootRoute == .othersProfile else { return }
        navigationPath.append(.othersEvents)
        print("navigation path ", navigationPath)
    }

    /// Navigates to the correct events list based on whose profile is shown.
    func goToAppropriateEvents() {
        navigationPath.append(isViewingOwnProfile ? .myEvents : .othersEvents)
    }

    func goToFriendsList() {
        navigationPath.append(.friendsList)
    }

    func goToMyEventDetails(eventId: String) {
        navigationPath.append(.myEventDetails(eventId: eventId))
    }

    func goToOthersEventDetails(eventId: String) {
        navigationPath.append(.othersEventDetails(eventId: eventId))
    }

    func goToOthersProfile(userId: String) {
        navigationPath.append(.othersProfile(userId: userId))
    }

    func goToEventConversations(eventId: String, eventTitle: String) {
        navigationPath.append(.eventConversations(eventId: eventId, eventTitle: eventTitle))
    }

    func goToScannedProfile(userId: String) {
        guard !userId.isEmpty else {
            logger.warning("goToScannedProfile called with empty userId — ignored")
            return
        }
        activeSheet = nil
        navigationPath.append(.scannedProfile(userId: userId))
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
