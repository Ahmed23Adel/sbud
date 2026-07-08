//
//  HomeCoordinator.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

//
//  HomeCoordinator.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import SwiftUI
import Combine

@MainActor
final class HomeCoordinator: ObservableObject {

    @Published var navigationPath: [HomeDestination] = []
    @Published var activeSheet: HomeSheet?

    weak var authDelegate: AuthCoordinatorDelegate?

    func goToMyEventDetail(eventId: String) {
        navigationPath.append(.myEventDetail(eventId: eventId))
    }

    func goToOthersEventDetail(eventId: String) {
        navigationPath.append(.othersEventDetail(eventId: eventId))
    }

    func goToProfile(userId: String) {
        navigationPath.append(.profileView(userId: userId))
    }

    func goToFriendsList(userId: String) {
        navigationPath.append(.friendsList(userId: userId))
    }

    func goToMyEvents(userId: String) {
        navigationPath.append(.myEvents(userId: userId))
    }

    func goToOthersEvents(userId: String) {
        navigationPath.append(.othersEvents(userId: userId))
    }

    func goToChat(user: UserProfile, eventId: String, eventTitle: String) {
        navigationPath.append(.chat(user: user, eventId: eventId, eventTitle: eventTitle))
    }

    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = []
    }

    func dismissSheet() {
        activeSheet = nil
    }
}
