//
//  AvailabilityAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI
import UIKit
//
//  The Availability tab's root container.
//  - Coordinator is @StateObject here because this IS the tab root.
//  - Filter state lives in AvailabilityViewModel — not in this view or the coordinator.
//  - Profile pushes reuse ProfileEmbedded (no new NavigationStack).
//

import SwiftUI
import UIKit

struct AvailabilityAppCoordinator: View {

    @StateObject private var coordinator = AvailabilityCoordinator()

    // authDelegate is passed in from HomeTabsView so logout can bubble up.
    weak var authDelegate: AuthCoordinatorDelegate?

    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            // Root view — passes coordinator down via environment.
            AvailbilityView()
                .ignoresSafeArea()
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: AvailabilityDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
        .ignoresSafeArea()
        .environmentObject(coordinator)
        .sheet(item: $coordinator.activeSheet) { sheet in
            sheetView(for: sheet)
        }
        .onChange(of: coordinator.activeSheet) { _, newValue in
            if newValue != nil {
                impactFeedback.impactOccurred(intensity: 0.8)
            }
        }
        .onAppear {
            coordinator.authDelegate = authDelegate
        }
    }

    // MARK: - Destinations

    @ViewBuilder
    private func destinationView(for destination: AvailabilityDestination) -> some View {
        switch destination {
        case .moreInfoEvent(let eventId):
            ViewMoreInfoEvent(eventId: eventId)

        case .addNewEvent:
            CoordinatorAddNewEvent()

        case .profile(let userId):
            // Reuses the existing NavigationStack — no nesting.
            // currentUserId resolved from ProfileManager here at the boundary.
            ProfileEmbedded(
                userId: userId,
                currentUserId: ProfileManager.shared.getLocalProfile()?.id ?? "",
                authDelegate: authDelegate
            )

        case .chat(let user, let eventId, let eventTitle):
            ChatView(user: user, eventId: eventId, eventTitle: eventTitle)
        }
    }

    // MARK: - Sheets

    @ViewBuilder
    private func sheetView(for sheet: AvailabilitySheet) -> some View {
        switch sheet {
        case .filter(let availabilityFiltersResults):
            FiltersView(availabilityFiltersResults: availabilityFiltersResults)
        }
    }
}
