//
//  OTPViewModel.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 14/04/26.
//

import Foundation
import Combine

@MainActor
class OTPViewModel: ObservableObject {
    @Published var otpCode: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMsg: String = ""
    
    let verificationID: String
    let phoneNumber: String
    var coordinator: MainCoordinator?
    private let authManager = AuthenticationManagerPhone.shared
    
    // Inizializziamo il ViewModel con i dati sicuri passati dal Coordinator
    init(verificationID: String, phoneNumber: String) {
        self.verificationID = verificationID
        self.phoneNumber = phoneNumber
    }
    
    func setCoordinator(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
    
    func verifyCodeAndSignIn() async {
        isLoading = true
        do {
            // Il manager ora ci dice se l'utente esiste già
            let isExistingUser = try await authManager.signInWithCode(
                verificationID: verificationID,
                verificationCode: otpCode
            )
            
            isLoading = false
            
            if isExistingUser {
                coordinator?.goToHome()
            } else {
                // Se è nuovo, lo mandiamo a una view per impostare username/email
                coordinator?.goToCompleteProfile(phoneNumber: phoneNumber)
            }
        } catch {
            isLoading = false
            showError("Code is wrong")
        }
    }
    
    private func showError(_ message: String) {
        self.alertMsg = message
        self.showAlert = true
    }
}
