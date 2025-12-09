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
    func signUpWithGoogle() async {
        do {
            try await authManager.signUpWithGoogle()
        } catch {
            await MainActor.run {
                showAlert = true
                alertMsg = "Problem with user registration, please try again"
            }
        }
        
        
    }
}
