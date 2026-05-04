//
//  ProfileCoordinator.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import Combine
import OSLog
import FirebaseAuth

class ProfileCoordinator: ObservableObject {
    @Published var currentRoute: ProfileRoute
    @Published var navigationPath: [ProfileRoutePushed] = []
    @Published var currUserId = ""
    @Published var sheetType: ProfileSheetType? = nil
    let logger = Logger(subsystem: "sbud", category: "ProfileCoordinator")

    var userIsCurUser: Bool {
        currUserId == ProfileManager.shared.getLocalProfile()!.id
    }

    init(userId: String) {
        self.currUserId = userId
        if userId == ProfileManager.shared.getLocalProfile()!.id {
            currentRoute = .myProfile
        } else {
            currentRoute = .othersProfile
        }
    }

    private func navigateTo(_ newRoute: ProfileRoute) {
        currentRoute = newRoute
    }

    private func push(_ newRoute: ProfileRoutePushed) {
        navigationPath.append(newRoute)
    }

    func goToAppropiateProfile(_ userId: String) {
        currUserId = userId
        navigationPath = []
        if userId == Auth.auth().currentUser?.uid {
            currentRoute = .myProfile
        } else {
            currentRoute = .othersProfile
        }
    }

    func goToSettings() {
        if currentRoute == .myProfile {
            navigationPath.append(.settings)
        }
    }

    func goToFriendRequests() {
        if currentRoute == .myProfile {
            navigationPath.append(.friendRequest)
        }
    }

    func goToMyEvents() {
        if currentRoute == .myProfile {
            navigationPath.append(.myEvents)
        }
    }

    func goToOthersEvent() {
        if currentRoute == .othersProfile {
            navigationPath.append(.othersEvents)
        }
    }

    func goToFriendsList() {
        if currentRoute == .myProfile {
            navigationPath.append(.friendsList)
        }
    }

    func goToAppropiateEvents() {
        if currentRoute == .myProfile {
            navigationPath.append(.myEvents)
        } else {
            navigationPath.append(.othersEvents)
        }
    }

    func goToMyEventDetails(eventId: String) {
        navigationPath.append(.viewMyEventDetails(eventId: eventId))
    }

    func goToProfileFromQueue(userId: String) {
        navigationPath.append(.viewOthersProfile(userId: userId))
    }

    func showHostsSheet(eventId: String) {
        if currentRoute == .myProfile {
            sheetType = .hosts(eventId: eventId)
        }
    }
}
