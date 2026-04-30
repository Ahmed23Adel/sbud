//
//  MainAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//
import SwiftUI

struct MainAppCoordinator: View {
    @StateObject private var coordinator = MainCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            ZStack {
                routeView
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: coordinator.currentRoute)

                VStack {
                    Spacer()
                    PopUpStackView()
                        .padding()
                }
            }
            .navigationDestination(for: MainRoute.self) { route in
                pushedView(for: route)
                    .environmentObject(coordinator)
            }
        }
        .environmentObject(coordinator)
    }

    // MARK: - Root route (replaces current screen)
    @ViewBuilder
    private var routeView: some View {
        switch coordinator.currentRoute {
        case .homePage:
            HomeTabsView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))
                .ignoresSafeArea()

        case .signUp:
            SignUpView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))
                .ignoresSafeArea()

        case .signIn:
            SignInView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))
                .ignoresSafeArea()

        case .profileSetup:
            ProfileSetupView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))
                .ignoresSafeArea()

        case .loadingPage:
            LoadingView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))
                .ignoresSafeArea()

        case .profilePage(let userId):
            ProfileView(userId: userId)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))

        case .settingsPage:
            SettingsView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))
                .ignoresSafeArea()

        case .friendList(let userId):
            FriendListView(userId: userId)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))

        case .friendRequests:
            FriendRequestsView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))

        case .myEvents:
            EmptyView() // always pushed, never a root
            
        case .editMyEvent:
            EmptyView()
        }
    }

    // MARK: - Pushed routes (native back button)
    @ViewBuilder
    private func pushedView(for route: MainRoute) -> some View {
        switch route {
        case .myEvents(let userId):
            ViewMyEvents(userId: userId)
        case .editMyEvent(let userId):
            ViewMyEventEdit(userId: userId)
        default:
            EmptyView()
        }
    }
}

#Preview {
    MainAppCoordinator()
}
#Preview {
    MainAppCoordinator()
}
