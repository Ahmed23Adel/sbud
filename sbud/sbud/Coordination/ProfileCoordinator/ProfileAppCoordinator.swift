//
//  ProfileAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct ProfileAppCoordinator: View {
    @StateObject private var coordinator: ProfileCoordinator
    let isEmbeddedInOldStack: Bool
    
    init(userId: String, isEmbedded: Bool){
        _coordinator = StateObject(wrappedValue: ProfileCoordinator(userId: userId))
        self.isEmbeddedInOldStack = isEmbedded
    }
    var body: some View {
        if isEmbeddedInOldStack {
            // No NavigationStack — use parent's stack
            rootView
                .navigationDestination(for: ProfileRoutePushed.self) { route in
                    destinationView(for: route)
                        .environmentObject(coordinator)
                }
                .environmentObject(coordinator)
                .sheet(item: $coordinator.sheetType){ sheet in
                    sheetView(for: sheet)
                        .environmentObject(coordinator)
                }
        } else {
            // Standalone tab — owns its NavigationStack
            NavigationStack(path: $coordinator.navigationPath) {
                rootView
                    .navigationDestination(for: ProfileRoutePushed.self) { route in
                        destinationView(for: route)
                            .environmentObject(coordinator)
                    }
            }
            .environmentObject(coordinator)
            .sheet(item: $coordinator.sheetType) { sheet in
                sheetView(for: sheet)
                    .environmentObject(coordinator)
            }
        }
    }
    
    @ViewBuilder
    private var rootView: some View {
        switch coordinator.currentRoute {
        case .myProfile:
            OwnProfileView(userId: coordinator.currUserId)
        case .othersProfile:
            OtherProfileView(userId: coordinator.currUserId )
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: ProfileRoutePushed) -> some View {
        switch route {
        case .settings:
            SettingsView()
        case .friendRequest:
            FriendRequestsView()
        case .myEvents:
            ViewMyEvents(userId: coordinator.currUserId)
        case .othersEvents:
            ViewOthersEvents(userId: coordinator.currUserId)
        case .friendsList:
            FriendListView(userId: coordinator.currUserId)
        case .viewMyEventDetails(let eventId):
            ViewMyEventDetails(eventId: eventId)
        case .editMyEvent:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func sheetView(for sheet: ProfileSheetType) -> some View {
        switch sheet {
        case .hosts(let eventId):
            ViewHosts(eventId: eventId)
        }
    }
}

#Preview {
    ProfileAppCoordinator(userId: "", isEmbedded: false)
}
