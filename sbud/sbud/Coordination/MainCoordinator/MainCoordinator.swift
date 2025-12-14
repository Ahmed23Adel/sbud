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

    init(authManager:  any IAuthenticationManager) {
        if authManager.checkAuthStatus() {
            currentRoute = .homePage
        } else {
            currentRoute = .signUp
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

}
