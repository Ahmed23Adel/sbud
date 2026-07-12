//
//  MainAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.

//
//  The root view of the app. Only job: render the correct screen
//  for the current MainRoute. Zero business logic here.
//

import SwiftUI

struct MainAppCoordinator: View {

    // Injected from SbudApp — not created here.
    @StateObject var coordinator: MainCoordinator

    var body: some View {
        ZStack(alignment: .bottom) {
            routeView
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.85),
                    value: coordinator.currentRoute
                )

            PopUpStackView()
                .padding()
        }
        .environmentObject(coordinator)
        .task {
            // Resolve the route once on first appearance.
            coordinator.resolveInitialRoute()
        }
    }

    // MARK: - Route Rendering

    @ViewBuilder
    private var routeView: some View {
        switch coordinator.currentRoute {

        case .loading:
            MidnightLoadingView()
                .transition(slideTransition)
                .ignoresSafeArea()

        case .signUp:
            SignUpView()
                .transition(slideTransition)
                .ignoresSafeArea()

        case .signIn:
            SignInView()
                .transition(slideTransition)
                .ignoresSafeArea()

        case .profileSetup:
            ProfileSetupView()
                .transition(slideTransition)
                .ignoresSafeArea()

        case .home:
            HomeTabsView()
                .ignoresSafeArea()

        case .creatorSession(let eventDetails, let isSessionCreated):
            ViewOwnerSession(
                eventDetails: eventDetails,
                isSessionCreated: isSessionCreated,
                delegate: coordinator
            )
            .transition(slideTransition)
            .ignoresSafeArea()

        case .othersSession(let eventDetails, let isSessionCreated):
            ViewOthersSession(
                eventDetails: eventDetails,
                isSessionCreated: isSessionCreated,
                delegate: coordinator
            )
            .transition(slideTransition)
            .ignoresSafeArea()
        case .sessionSummary(let eventDetails):
            NavigationStack {
                ViewSessionSummaryConditional(
                    event: eventDetails,
                    onBack: { coordinator.goToHome() }
                )
            }
            .transition(slideTransition)
        }
    }

    // MARK: - Shared Transition

    private var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
