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
        self.checkAppFlow()
    }
    
    func checkAppFlow() {
            Task {
                let target = await checkProfileStatus()
                self.currentRoute = target
                navigateTo(target)
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
    
    func goToLoading() {
        navigateTo(.loadingPage)
    }
}
