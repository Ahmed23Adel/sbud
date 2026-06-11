//
//  HomeAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

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
    @State private var viewModel = HomeViewModel()
    @EnvironmentObject private var mainCoordinator: MainCoordinator
    weak var authDelegate: AuthCoordinatorDelegate?

    private var currentUserId: String {
        ProfileManager.shared.getLocalProfile()?.id ?? ""
    }

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            HomeView(
                viewModel: viewModel,
                onTapMyEvent: { eventId in coordinator.goToMyEventDetail(eventId: eventId) },
                onTapOthersEvent: { eventId in coordinator.goToOthersEventDetail(eventId: eventId) },
                onTapProfile: { userId in coordinator.goToProfile(userId: userId) }
            )
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: HomeDestination.self) { destination in
                destinationView(for: destination)
            }
        }
        .environmentObject(coordinator)
        .sheet(item: $coordinator.activeSheet) { sheet in
            sheetView(for: sheet)
        }
        .onAppear {
            coordinator.authDelegate = authDelegate
        }
        .overlay {
            if viewModel.isLoading && viewModel.upcomingEvents.isEmpty {
                ZStack {
                    Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()
                    LoadingView()
                }
                .transition(.opacity)
                .animation(.easeOut(duration: 0.3), value: viewModel.isLoading)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for destination: HomeDestination) -> some View {
        switch destination {

        case .myEventDetail(let eventId), .myEventDetails(let eventId):
            ViewMyEventDetails(eventId: eventId)
                .environmentObject(makeProfileCoordinator(userId: currentUserId, currentUserId: currentUserId))
                .environmentObject(mainCoordinator)

        case .othersEventDetail(let eventId), .othersEventDetails(let eventId):
            ViewMoreInfoEvent(eventId: eventId)
                .environmentObject(makeAvailabilityCoordinator())

        case .profileView(let userId):
            ProfileEmbedded(
                userId: userId,
                currentUserId: currentUserId,
                authDelegate: authDelegate,
                onPush: { route in handleProfileRoute(route) }
            )

        case .othersEvents(let userId):
            ViewOthersEvents(userId: userId) { eventId in
                coordinator.goToOthersEventDetail(eventId: eventId)
            }
            .environmentObject(makeProfileCoordinator(userId: userId, currentUserId: currentUserId))

        case .myEvents(let userId):
            ViewCombinedEvents(
                userId: userId,
                onCreatedEventTap: { eventId in coordinator.goToMyEventDetail(eventId: eventId) },
                onParticipatedEventTap: { eventId in coordinator.goToOthersEventDetail(eventId: eventId) }
            )
            .environmentObject(makeProfileCoordinator(userId: userId, currentUserId: currentUserId))

        case .friendsList(let userId):
            FriendListView(userId: userId)
                .environmentObject(makeProfileCoordinator(userId: userId, currentUserId: currentUserId))

        case .chat(let user, let eventId, let eventTitle):
            ChatView(user: user, eventId: eventId, eventTitle: eventTitle)
        }
    }

    // MARK: - Helpers

    private func makeProfileCoordinator(userId: String, currentUserId: String) -> ProfileCoordinator {
        let pc = ProfileCoordinator(userId: userId, currentUserId: currentUserId)
        pc.onPush = { route in handleProfileRoute(route) }
        return pc
    }

    private func makeAvailabilityCoordinator() -> AvailabilityCoordinator {
        let ac = AvailabilityCoordinator()
        ac.onShowProfile = { userId in coordinator.goToProfile(userId: userId) }
        ac.onShowChat = { user, eventId, eventTitle in
            coordinator.goToChat(user: user, eventId: eventId, eventTitle: eventTitle)
        }
        return ac
    }

    private func handleProfileRoute(_ route: ProfileRoutePushed) {
        switch route {
        case .othersProfile(let userId), .scannedProfile(let userId):
            coordinator.goToProfile(userId: userId)
        case .myEventDetails(let eventId):
            coordinator.goToMyEventDetail(eventId: eventId)
        case .othersEventDetails(let eventId):
            coordinator.goToOthersEventDetail(eventId: eventId)
        case .friendsList(let userId):
            coordinator.goToFriendsList(userId: userId)
        case .othersEvents(let userId):
            coordinator.goToOthersEvents(userId: userId)
        case .myEvents(let userId):
            coordinator.goToMyEvents(userId: userId)
        default:
            break
        }
    }

    @ViewBuilder
    private func sheetView(for sheet: HomeSheet) -> some View {
        EmptyView()
    }
}
