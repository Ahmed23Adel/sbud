//
//  AvailabilityAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

//  Manages navigation within the Availability tab.
//  Filter state lives in a ViewModel, not in this coordinator.
//

import Foundation
import SwiftUI
import OSLog
import Combine

@MainActor
final class AvailabilityCoordinator: ObservableObject {

    // MARK: - Published State

    @Published var navigationPath = NavigationPath()
    @Published var activeSheet: AvailabilitySheet?

    // MARK: - Dependencies

    /// Weak — MainCoordinator conforms to this if auth actions are ever needed from here.
    weak var authDelegate: AuthCoordinatorDelegate?

    private let logger = Logger(subsystem: "sbud", category: "AvailabilityCoordinator")

    // MARK: - Push Navigation

    func showMoreInfo(eventId: String) {
        navigationPath.append(AvailabilityDestination.moreInfoEvent(eventId: eventId))
    }

    func showAddNewEvent() {
        navigationPath.append(AvailabilityDestination.addNewEvent)
    }

    func showProfile(userId: String) {
        navigationPath.append(AvailabilityDestination.profile(userId: userId))
    }

    func showChat(user: UserProfile, eventId: String, eventTitle: String) {
        navigationPath.append(AvailabilityDestination.chat(user: user, eventId: eventId, eventTitle: eventTitle))
    }

    // MARK: - Pop Navigation

    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }

    // MARK: - Sheets

    func showFilterSheet(availFilters: Binding<AvailabilityFiltersResults>) {
        activeSheet = .filter(availabilityFiltersResults: availFilters)
    }

    func dismissSheet() {
        activeSheet = nil
    }
}
