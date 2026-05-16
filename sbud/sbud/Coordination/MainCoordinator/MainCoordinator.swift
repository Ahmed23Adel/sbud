//
//  Coordinator.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//

import Foundation
import Combine
import OSLog
class MainCoordinator: ObservableObject {
    @Published var currentRoute: MainRoute
    let logger = Logger(subsystem: "sbud", category: "MainCoordinator")
    
    let authManager = AuthenticationManager.shared
    let profManager = ProfileManager.shared

    private var routeStack: [MainRoute] = []

    init() {
        self.currentRoute = .loadingPage
        checkAppFlow()
    }

    var canGoBack: Bool {
        !routeStack.isEmpty
    }
    
    func goBack() {
        currentRoute = .homePage
    }

    func navigateTo(_ route: MainRoute) {
        switch route {
        case .profilePage:
            routeStack.append(currentRoute)
        default:
            routeStack.removeAll()
        }
        currentRoute = route
    }

    
    func goToSignUp()  { navigateTo(.signUp) }
    func goToSignIn()  { navigateTo(.signIn) }
    func goToHome()    { navigateTo(.homePage) }

    func goToProfile(userId: String) {
        navigateTo(.profilePage(userId: userId))
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
            if profManager.isProfileSetupComplete {
                return .homePage
            } else {
                await FCMExtractor().saveFCMToken()
                return .profileSetup
            }
        } catch {
            await FCMExtractor().saveFCMToken()
            return .profileSetup
        }
    }
    
    
    
    
}
