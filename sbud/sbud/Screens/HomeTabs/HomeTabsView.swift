//
//  HomeTabView.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import SwiftUI

struct HomeTabsView: View {
    @StateObject var viewModel = HomeTabsViewModel()
    @EnvironmentObject private var coordinator: MainCoordinator
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            AvailabilityAppCoordinator()
                .ignoresSafeArea()
                .tabItem {
                    Label("Availability", systemImage: "figure.run")
                }
                .tag(1)
            AllEventsView()
                .tabItem {
                    Label("Events", systemImage: "person.3")
                }
                .tag(2)
            ProfileAppCoordinator(userId: ProfileManager.shared.getLocalProfile()!.id, isEmbedded: false)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomeTabsView()
}
