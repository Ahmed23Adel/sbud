//
//  AllEventsCoordinator.swift.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import Foundation
//
//  AllEventsCoordinator.swift
//  sbud
//
//  Scaffold for the All Events tab coordinator.
//  Follows the exact same pattern as HomeCoordinator and AvailabilityCoordinator.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Route Types (scaffold — add cases as needed)

enum AllEventsDestination: Hashable, Equatable {
    // e.g. case eventDetail(eventId: String)
    // e.g. case hostProfile(userId: String)
}

enum AllEventsSheet: Identifiable {
    // e.g. case filters

    var id: String {
        return "placeholder"
    }
}

// MARK: - Coordinator

@MainActor
final class AllEventsCoordinator: ObservableObject {

    @Published var navigationPath = NavigationPath()
    @Published var activeSheet: AllEventsSheet?

    weak var authDelegate: AuthCoordinatorDelegate?

    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }

    func dismissSheet() {
        activeSheet = nil
    }
}

// MARK: - Root View

struct AllEventsAppCoordinator: View {

    @StateObject private var coordinator = AllEventsCoordinator()
    weak var authDelegate: AuthCoordinatorDelegate?

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            AllEventsView()
                .ignoresSafeArea()
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: AllEventsDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
        .ignoresSafeArea()
        .environmentObject(coordinator)
        .sheet(item: $coordinator.activeSheet) { sheet in
            sheetView(for: sheet)
        }
        .onAppear {
            coordinator.authDelegate = authDelegate
        }
    }

    @ViewBuilder
    private func destinationView(for destination: AllEventsDestination) -> some View {
        EmptyView()
    }

    @ViewBuilder
    private func sheetView(for sheet: AllEventsSheet) -> some View {
        EmptyView()
    }
}
