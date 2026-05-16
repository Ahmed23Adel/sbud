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
        ZStack {
            routeView
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: coordinator.currentRoute)

            VStack {
                Spacer()
                PopUpStackView()
                    .padding()
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
                    removal:   .move(edge: .leading).combined(with: .opacity)))
                .ignoresSafeArea()

        case .loadingPage:
            LoadingView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)))
                .ignoresSafeArea()
            
        case .session(let eventDetails, let isSessionCreated):
            ViewOwnerSession(eventDetails: eventDetails, isSessionCreated: isSessionCreated)
                .environmentObject(coordinator)
        default:
            EmptyView()
        
        }
    }

    // MARK: - Pushed routes (native back button)
    @ViewBuilder
    private func pushedView(for route: MainRoute) -> some View {
        switch route {
        default:
            EmptyView()
        }
    }
}

#Preview {
    MainAppCoordinator()
}
