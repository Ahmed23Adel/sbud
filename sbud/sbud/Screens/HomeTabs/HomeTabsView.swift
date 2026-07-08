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
    @State private var deepLinkedUserId: String? = nil
    @State private var deepLinkedEventId: String? = nil

    var body: some View {
        if let profile = ProfileManager.shared.getLocalProfile() {
            TabView(selection: $viewModel.selectedTab) {
                HomeAppCoordinator()
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
                StoriesTabRoot()
                    .tabItem {
                        Label("Stories", systemImage: "play.circle.fill")
                    }
                    .tag(2)
                ProfileTabRoot(
                    userId: profile.id,
                    currentUserId: profile.id,
                    authDelegate: coordinator,
                    deepLinkedUserId: $deepLinkedUserId,
                    deepLinkedEventId: $deepLinkedEventId
                )
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
                .badge(viewModel.totalNotificationsCount)
            }
            .ignoresSafeArea()
            .onAppear {
                viewModel.listenForUnreadMessages()
            }
            .onChange(of: coordinator.deepLinkProfileUserId) { _, userId in
                guard let userId else { return }
                coordinator.deepLinkProfileUserId = nil
                viewModel.selectedTab = 3
                deepLinkedUserId = userId
            }
            .onChange(of: coordinator.deepLinkEventId) { _, eventId in
                guard let eventId else { return }
                coordinator.deepLinkEventId = nil
                viewModel.selectedTab = 3
                deepLinkedEventId = eventId
            }
        } else {
            Color.darkBackground.ignoresSafeArea()
        }
    }
}

#Preview {
    HomeTabsView()
}
