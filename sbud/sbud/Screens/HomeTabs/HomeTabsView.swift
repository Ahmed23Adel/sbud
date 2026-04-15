//
//  HomeTabView.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import SwiftUI

struct HomeTabsView: View {
    @StateObject var viewModel = HomeTabsViewModel()

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
            NavigationStack {
                    ConversationsView()
                }
                .tabItem { Label("Messages", systemImage: "envelope.fill") }
                .tag(3)
            PersonalView()
                .tabItem {
                    Label("Personal", systemImage: "person")
                }
                .tag(4)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomeTabsView()
}
