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
    
    init() {
        self.currentRoute = .loadingPage
        checkAppFlow()
    }

    func navigateTo(_ route: MainRoute) {
        currentRoute = route
    }

    func goToSignUp() {
        navigateTo(.signUp)
    }

    func goToSignIn() {
        navigateTo(.signIn)
    }

    func goToHome() {
        navigateTo(.homePage)
    }
    
    func goToProfile(userId: String) {
        navigateTo(.profilePage(userId: userId))
    }

    func goBack() {
        navigateTo(.homePage)
    }
    
    func logout(){
        profManager.deleteProfileFromLocale()
        goToSignUp()
    }
    
    func refreshAppFlow() {
            checkAppFlow()
        }
    
    func checkAppFlow() {
            Task { @MainActor in
                let target = await checkProfileStatus()
                navigateTo(target)
                lastSeenUpdate()
            }
        }
    
    func lastSeenUpdate() {
        Task {
            await profManager.updateLastSeen()
        }
    }

    private func checkProfileStatus() async -> MainRoute {
    
        guard authManager.checkAuthStatus() else {  return .signUp  }
        if profManager.isProfileSetupComplete { return .homePage    }
    
        do {
            try await profManager.syncProfileAfterLogin()
            return profManager.isProfileSetupComplete ? .homePage : .profileSetup
        } catch {
            return .profileSetup
        }
    }
}
