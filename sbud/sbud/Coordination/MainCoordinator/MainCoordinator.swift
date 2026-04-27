//
//  Coordinator.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//

import Foundation
import Combine

class MainCoordinator: ObservableObject {
    @Published var currentRoute: MainRoute

    let authManager = AuthenticationManager.shared
    let profManager = ProfileManager.shared

    private var routeStack: [MainRoute] = []

    init() {
        self.currentRoute = .loadingPage
        checkAppFlow()
    }

    func navigateTo(_ route: MainRoute) {
        switch route {
        case .settingsPage, .profilePage:
            routeStack.append(currentRoute)
        default:
            routeStack.removeAll()
        }
            currentRoute = route
    }

    func goBack() {
        guard let previous = routeStack.popLast() else {
            currentRoute = .homePage
            return
        }
            currentRoute = previous
    }

    func goToSignUp()  { navigateTo(.signUp) }
    func goToSignIn()  { navigateTo(.signIn) }
    func goToHome()    { navigateTo(.homePage) }

    func goToProfile(userId: String) {
        navigateTo(.profilePage(userId: userId))
    }

    func goToSettings() {
        navigateTo(.settingsPage)
    }

    func logout() {
        routeStack.removeAll()
        profManager.deleteProfileFromLocale()
        currentRoute = .signUp
    }

    func refreshAppFlow() {
        checkAppFlow()
    }

    func checkAppFlow() {
        Task { @MainActor in
            let target = await checkProfileStatus()
            routeStack.removeAll()
            currentRoute = target
        }
    }

    private func checkProfileStatus() async -> MainRoute {
        guard authManager.checkAuthStatus() else { return .signUp }
        if profManager.isProfileSetupComplete { return .homePage }

        do {
            try await profManager.syncProfileAfterLogin()
            return profManager.isProfileSetupComplete ? .homePage : .profileSetup
        } catch {
            return .profileSetup
        }
    }
}
