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
    @Published var deepLinkProfileUserId: String? = nil
    @Published var deepLinkEventId: String? = nil
    private var pendingProfileUserId: String? = nil
    private var pendingEventId: String? = nil

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
        openPendingProfileIfNeeded()
        openPendingEventIfNeeded()
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

// MARK: - Deep Link / URL Handling

extension MainCoordinator {
    /// Handles both custom scheme (sbud://profile/<id>)
    /// and universal links (https://sbud-backend.onrender.com/profile/<id>).
    func handle(universalLink url: URL) {
        guard let scheme = url.scheme else { return }

        if scheme == "sbud" {
            let host = url.host
            let id = url.pathComponents.filter { $0 != "/" }.first

            if host == "profile", let userId = id {
                pendingProfileUserId = userId
            } else if host == "event", let eventId = id {
                pendingEventId = eventId
            } else {
                return
            }
        } else if url.host == "sbud-backend.onrender.com" {
            let parts = url.pathComponents.filter { $0 != "/" }
            guard parts.count >= 2 else { return }
            if parts[0] == "profile" {
                pendingProfileUserId = parts[1]
            } else if parts[0] == "event" {
                pendingEventId = parts[1]
            } else {
                return
            }
        } else {
            return
        }

        if currentRoute == .home {
            openPendingProfileIfNeeded()
            openPendingEventIfNeeded()
        }
    }

    func openPendingProfileIfNeeded() {
        guard let userId = pendingProfileUserId else { return }
        pendingProfileUserId = nil
        deepLinkProfileUserId = userId
    }

    func openPendingEventIfNeeded() {
        guard let eventId = pendingEventId else { return }
        pendingEventId = nil
        deepLinkEventId = eventId
    }
}

// MARK: - SessionCoordinatorDelegate

extension MainCoordinator: SessionCoordinatorDelegate {
    func sessionDidEnd() {
        currentRoute = .home
    }
}
