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
    
    @Published var showPassword = false
    var isFormValid: Bool {
        return isValidEmail(email) && password.count > 6
    }
    
    func setCoordinator(coordinator: MainCoordinator){
        self.coordinator = coordinator
    }
    
    // MARK: auth Google
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
    
    // MARK: auth Email
    func singIn () async throws{
        isSigningIn = true
        authManager.setAuthTypeEmailAndPassword()
        do{
            try await authManager.signIn(email: email, password: password)
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
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
