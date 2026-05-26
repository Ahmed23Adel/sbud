//
//  HomeAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import SwiftUI
import Combine

struct HomeAppCoordinator: View {
 
    @StateObject private var coordinator = HomeCoordinator()
    weak var authDelegate: AuthCoordinatorDelegate?
 
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            HomeView()
                .ignoresSafeArea()
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: HomeDestination.self) { destination in
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
    private func destinationView(for destination: HomeDestination) -> some View {
        // Add cases as HomeView grows.
        EmptyView()
    }
 
    @ViewBuilder
    private func sheetView(for sheet: HomeSheet) -> some View {
        // Add cases as HomeView grows.
        EmptyView()
    }
}
