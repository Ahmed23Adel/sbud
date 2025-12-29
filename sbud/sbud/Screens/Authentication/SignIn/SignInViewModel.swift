//
//  SignInViewModel.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation
import Combine

@MainActor
class SignInViewModel: ObservableObject{
    
    let authManager = AuthenticationManager.shared
    @Published var showAlert = false
    @Published var alertMsg = ""
    var coordinator: MainCoordinator?
    @Published var email = ""
    @Published var password = ""
    @Published var isSigningIn = false
    
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
    
    func singIn () async throws{
        isSigningIn = true
        do{
            try await AuthenticationManagerEmailAndPassword.shared.signIn(withEmail: email, password: password)
            isSigningIn = false
            coordinator?.goToHome()
        } catch {
            isSigningIn = false
            showAlert = true
                alertMsg = "Email or password are incorrect, please try again"
            
        }
    }
    
    func goToSignUp(){
        coordinator?.goToSignUp()
    }
}
