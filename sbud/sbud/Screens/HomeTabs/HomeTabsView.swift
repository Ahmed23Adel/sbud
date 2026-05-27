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
        if let profile = ProfileManager.shared.getLocalProfile() {
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
                ProfileTabRoot(userId: profile.id, currentUserId: profile.id, authDelegate: coordinator)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
                    .badge(viewModel.unreadMessagesCount)
            }
            .ignoresSafeArea()
            .onAppear {
                viewModel.listenForUnreadMessages()
            }
        } else {
            Color.darkBackground.ignoresSafeArea()
        }
    }
}

#Preview {
    HomeTabsView()
}
