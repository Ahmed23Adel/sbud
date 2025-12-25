//
//  SignUpViewModel.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class SignUpViewModel: ObservableObject{
    @Published var email: String = ""
    @Published var password: String =  ""
    @Published var username: String = ""
    @Published var emailIsValid = false //to ensure
    @Published var usernameIsValid = false
    @Published var isLoading = false
    @Published var emailValidationFailed = false
    @Published var usernameValidationFailed = false
    @Published var isSigningUp = false
    let authManager = AuthenticationManager.shared
    @Published var showAlert = false
    @Published var alertMsg = ""
    var coordinator: MainCoordinator?
    
    init(){
        
    }
    
    func setCoordinator(coordinator: MainCoordinator){
        self.coordinator = coordinator
    }

    func signUpWithGoogle() async {
        authManager.setAuthTypeGoogle()
        do {
            try await authManager.signUp()
            coordinator?.goToHome()
        } catch {
            await MainActor.run {
                showAlert = true
                alertMsg = "Problem with user registration, please try again"
            }
        }        
    }
    
    func goToSignIn(){
        coordinator?.goToSignIn()
    }
    
    func createUser() async throws {
        isSigningUp = true
        do{
            try await AuthenticationManagerEmailAndPassword.shared.signUp(email: email, password: password, username: username)
            print("Tentativo di navigazione via coordinator: \(String(describing: coordinator))")
            isSigningUp = false
            coordinator?.goToHome()
        } catch {
            isSigningUp = false
            showAlert = true
            
            // 1. Convertiamo l'errore Swift in NSError per leggere il codice numerico
            let nsError = error as NSError
            
            // 2. Usiamo AuthErrorCode(rawValue:) direttamente (senza .Code)
            if let errorCode = AuthErrorCode(rawValue: nsError.code) {
                switch errorCode {
                case .emailAlreadyInUse:
                    alertMsg = "This email is already in use. Try sign in"
                case .invalidEmail:
                    alertMsg = "Format of the email is wrong."
                case .weakPassword:
                    alertMsg = "The password is too short. (minimum 6 characters)"
                default:
                    alertMsg = "Error: \(error.localizedDescription)"
                }
            } else {
                alertMsg = "Generic error: \(error.localizedDescription)"
            }
        }
    }
    
    @MainActor
    func validateEmail() async throws {
        self.isLoading = true
        self.emailValidationFailed = false
        
        let snapshot = try await Firestore.firestore().collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments()
        
        self.emailValidationFailed = !snapshot.isEmpty
        self.emailIsValid = snapshot.isEmpty
        
        self.isLoading = false
    }
    
    @MainActor
    func validateUsername() async throws {
        self.isLoading = true
        
        let snapshot = try await Firestore.firestore().collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments()
        
        self.usernameIsValid = snapshot.isEmpty
        self.isLoading = false
    }
    
}
