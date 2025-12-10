//
//  SignInViewModel.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation
import Combine

class SignInViewModel: ObservableObject{
    
    let authManager = AuthenticationManager.shared
    @Published var showAlert = false
    @Published var alertMsg = ""
    var coordinator: MainCoordinator?
    
    func setCoordinator(coordinator: MainCoordinator){
        self.coordinator = coordinator
    }
    
    func signUpWithGoogle() async {
        authManager.setAuthTypeGoogle()
        do {
            try await authManager.signIn()
            coordinator?.goToHome()
        } catch {
            await MainActor.run {
                showAlert = true
                alertMsg = "Problem with user registration, please try again"
            }
        }
    }
    
    func goToSignUp(){
        coordinator?.goToSignUp()
    }
}
