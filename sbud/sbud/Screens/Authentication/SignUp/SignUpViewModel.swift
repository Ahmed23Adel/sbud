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

class SignUpViewModel: ObservableObject{
    
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
    
}
