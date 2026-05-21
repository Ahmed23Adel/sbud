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
                    ProfileDestinationView(
                        route: route,
                        userId: coordinator.userId,
                        currentUserId: coordinator.userId,
                        authDelegate: authDelegate,
                        pushToParent: { nextRoute in
                            coordinator.navigationPath.append(nextRoute)
                        }
                    )
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
//


import SwiftUI

struct ProfileEmbedded: View {
    let userId: String
    let currentUserId: String
    weak var authDelegate: AuthCoordinatorDelegate?

    // Called when this profile wants to push a new route.
    // The PARENT coordinator executes the actual append to its NavigationPath.
    let onPush: (ProfileRoutePushed) -> Void

    @StateObject private var coordinator: ProfileCoordinator

    init(
        userId: String,
        currentUserId: String,
        authDelegate: AuthCoordinatorDelegate?,
        onPush: @escaping (ProfileRoutePushed) -> Void
    ) {
        self.userId = userId
        self.currentUserId = currentUserId
        self.authDelegate = authDelegate
        self.onPush = onPush
        _coordinator = StateObject(
            wrappedValue: ProfileCoordinator(
                userId: userId,
                currentUserId: currentUserId
            )
        )
    }

    var body: some View {
        profileRootView
            .environmentObject(coordinator)
            .sheet(item: $coordinator.activeSheet) { sheet in
                ProfileSheetView(sheet: sheet)
                    .environmentObject(coordinator)
            }
            .onAppear {
                coordinator.delegate = authDelegate
                // Wire all push navigation from this coordinator
                // into the parent stack's NavigationPath.
                coordinator.onPush = onPush
            }
    }

    @ViewBuilder
    private var profileRootView: some View {
        switch coordinator.rootRoute {
        case .myProfile:
            OwnProfileView(userId: coordinator.userId)
        case .othersProfile:
            OtherProfileView(userId: coordinator.userId)
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
//
//  ProfileDestinationView.swift
//  sbud
//
//  Shared destination renderer for ProfileRoutePushed.
//  Used by any NavigationStack that can push into profile territory.
//

import SwiftUI

// ProfileDestinationView.swift

struct ProfileDestinationView: View {
    let route: ProfileRoutePushed
    let userId: String          // explicit — no environment lookup
    let currentUserId: String
    weak var authDelegate: AuthCoordinatorDelegate?
    let pushToParent: (ProfileRoutePushed) -> Void  // always the root stack's append

    var body: some View {
        switch route {
        case .settings:
            SettingsView()

        case .friendRequests:
            FriendRequestsView()

        case .hostRequests:
            ViewHostsRequests()

        case .myEvents:
            ViewCombinedEvents(userId: userId)

        case .othersEvents:
            ViewOthersEvents(userId: userId)

        case .friendsList:
            FriendListView(userId: userId)

        case .myEventDetails(let eventId):
            ViewMyEventDetails(eventId: eventId)

        case .othersEventDetails(let eventId):
            ViewOthersEventDetails(eventId: eventId)

        case .othersProfile(let targetId), .scannedProfile(let targetId):
            ProfileEmbedded(
                userId: targetId,
                currentUserId: currentUserId,
                authDelegate: authDelegate,
                onPush: pushToParent  // same root stack all the way down
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
                coordinator.goToScannedProfile(userId: coordinator.userId)
            }
        }
    }
}
