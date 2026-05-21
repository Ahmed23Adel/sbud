//
//  ProfileAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

//  Renders the profile navigation stack.
//
//  When used as a tab root: wrap in NavigationStack here.
//  When pushed inside another NavigationStack: use ProfileAppCoordinator
//  directly as a navigationDestination — NavigationStack is NOT nested.
//

import SwiftUI

// MARK: - Tab Root Entry Point

/// Use this when ProfileAppCoordinator is the root of a tab.
/// It owns its NavigationStack.
struct ProfileTabRoot: View {
    @StateObject private var coordinator: ProfileCoordinator
    weak var authDelegate: AuthCoordinatorDelegate?

    init(userId: String, currentUserId: String, authDelegate: AuthCoordinatorDelegate?) {
        _coordinator = StateObject(
            wrappedValue: ProfileCoordinator(userId: userId, currentUserId: currentUserId)
        )
        self.authDelegate = authDelegate
    }

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            ProfileAppCoordinator()
                .navigationDestination(for: ProfileRoutePushed.self) { route in
                    ProfileDestinationView(route: route)
                }
        }
        .environmentObject(coordinator)
        .sheet(item: $coordinator.activeSheet) { sheet in
            ProfileSheetView(sheet: sheet)
                .environmentObject(coordinator)
        }
        .onAppear {
            coordinator.delegate = authDelegate
        }
    }
}

// MARK: - Embedded Entry Point (pushed inside a parent NavigationStack)

/// Use this when pushing a profile inside an existing NavigationStack.
/// No new NavigationStack is created here.
struct ProfileEmbedded: View {
    @StateObject private var coordinator: ProfileCoordinator
    weak var authDelegate: AuthCoordinatorDelegate?

    init(userId: String, currentUserId: String, authDelegate: AuthCoordinatorDelegate?) {
        _coordinator = StateObject(
            wrappedValue: ProfileCoordinator(userId: userId, currentUserId: currentUserId)
        )
        self.authDelegate = authDelegate
    }

    var body: some View {
        ProfileAppCoordinator()
            .navigationDestination(for: ProfileRoutePushed.self) { route in
                ProfileDestinationView(route: route)
            }
            .environmentObject(coordinator)
            .sheet(item: $coordinator.activeSheet) { sheet in
                ProfileSheetView(sheet: sheet)
                    .environmentObject(coordinator)
            }
            .onAppear {
                coordinator.delegate = authDelegate
            }
    }
}

// MARK: - Root Content View

/// Renders either OwnProfileView or OtherProfileView based on coordinator state.
private struct ProfileAppCoordinator: View {
    @EnvironmentObject private var coordinator: ProfileCoordinator

    var body: some View {
        switch coordinator.rootRoute {
        case .myProfile:
            OwnProfileView(userId: coordinator.userId)
        case .othersProfile:
            OtherProfileView(userId: coordinator.userId)
        }
    }
}

// MARK: - Destination View (pushed routes)

private struct ProfileDestinationView: View {
    let route: ProfileRoutePushed
    @EnvironmentObject private var coordinator: ProfileCoordinator

    var body: some View {
        switch route {
        case .settings:
            SettingsView()

        case .friendRequests:
            FriendRequestsView()

        case .hostRequests:
            ViewHostsRequests()

        case .myEvents:
            ViewCombinedEvents(userId: coordinator.userId)

        case .othersEvents:
            ViewOthersEvents(userId: coordinator.userId)

        case .friendsList:
            FriendListView(userId: coordinator.userId)

        case .myEventDetails(let eventId):
            ViewMyEventDetails(eventId: eventId)

        case .othersEventDetails(let eventId):
            ViewOthersEventDetails(eventId: eventId)

        case .othersProfile(let userId), .scannedProfile(let userId):
            // Pushed inside the existing NavigationStack — no new stack.
            ProfileEmbedded(
                userId: userId,
                currentUserId: coordinator.userId,
                authDelegate: coordinator.delegate
            )

        case .eventConversations(let eventId, let eventTitle):
            EventConversationsView(eventId: eventId, eventTitle: eventTitle)
        }
    }
}

// MARK: - Sheet View

private struct ProfileSheetView: View {
    let sheet: ProfileSheetType
    @EnvironmentObject private var coordinator: ProfileCoordinator

    var body: some View {
        switch sheet {
        case .hosts(let eventId):
            ViewHosts(eventId: eventId, userId: coordinator.userId)

        case .qrCode:
            QRCodeSheetView(userId: coordinator.userId) { scannedId in
                coordinator.goToScannedProfile(userId: scannedId)
            }
        }
    }
}
