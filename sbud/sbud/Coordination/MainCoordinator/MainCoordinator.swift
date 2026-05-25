//
//  Coordinator.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//
//
//  MainCoordinator.swift
//  sbud
//
//  Owns the top-level route state.
//  Responsibilities: determine initial route, handle auth events, manage session takeover.
//  Does NOT: touch Firebase directly, build HTTP requests, save FCM tokens.
//

import Foundation
import OSLog
import Combine

@MainActor
final class MainCoordinator: ObservableObject {

    // MARK: - Published State

    @Published private(set) var currentRoute: MainRoute = .loading

    // MARK: - Private Dependencies

    private let authService: IAuthenticationManager
    private let profileService: IProfileServiceManager
    private let logger = Logger(subsystem: "sbud", category: "MainCoordinator")

    // MARK: - Init

    init(
        authService: IAuthenticationManager,
        profileService: IProfileServiceManager
    ) {
        self.authService = authService
        self.profileService = profileService
    }

    // MARK: - App Flow

    /// Called once on launch from the root view. Determines where the user lands.
    func resolveInitialRoute() {
        Task {
            currentRoute = await determineRoute()
        }
    }

    // MARK: - Navigation

    func navigateTo(_ route: MainRoute) {
        currentRoute = route
    }

    func goToHome() {
        currentRoute = .home
    }

    func goToSignUp() {
        currentRoute = .signUp
    }
    
    func goToSignIn() {
        currentRoute = .signIn
    }

    func startCreatorSession(eventDetails: EventFullDetails, isSessionCreated: Bool) {
        currentRoute = .creatorSession(eventDetails: eventDetails, isSessionCreated: isSessionCreated)
    }

    func startOthersSession(eventDetails: EventFullDetails, isSessionCreated: Bool) {
        currentRoute = .othersSession(eventDetails: eventDetails, isSessionCreated: isSessionCreated)
    }

    // MARK: - Private Route Resolution

    private func determineRoute() async -> MainRoute {
        guard authService.checkAuthStatus() else {
            return .signUp
        }

        if profileService.isProfileSetupComplete {
            return .home
        }

        do {
            try await profileService.syncProfileAfterLogin()
            return profileService.isProfileSetupComplete ? .home : .profileSetup
        } catch {
            logger.error("Profile sync failed: \(error.localizedDescription)")
            return .profileSetup
        }
    }
}

// MARK: - AuthCoordinatorDelegate

/// Child coordinators (Profile → Settings) call these when the user
/// triggers auth-level actions. MainCoordinator handles the result.
extension MainCoordinator: AuthCoordinatorDelegate {

    func coordinatorDidRequestLogout() {
        print("coordinatorDidRequestLogouttttt")
        profileService.deleteProfileFromLocale()
        Task {
            do {
                try await authService.signOut()
            } catch {
                logger.error("Sign out failed: \(error.localizedDescription)")
            }
            
        }
        
        currentRoute = .signUp
    }

    func coordinatorDidCompleteSignIn() {
        Task {
            currentRoute = await determineRoute()
        }
    }

    func coordinatorDidCompleteProfileSetup() {
        currentRoute = .home
    }
}

// MARK: - SessionCoordinatorDelegate

extension MainCoordinator: SessionCoordinatorDelegate {
    func sessionDidEnd() {
        currentRoute = .home
    }
}
