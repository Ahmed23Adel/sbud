//
//  PhoneAuthViewModel.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 26/03/26.
//

import Foundation
import Combine

@MainActor
class PhoneLoginViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMsg: String = ""
    
    var coordinator: MainCoordinator?
    private let authManager = AuthenticationManagerPhone.shared
    
    func setCoordinator(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }
    
    func sendVerificationCode() async {
        // Controllo base (assicurati che l'utente metta il prefisso)
        guard phoneNumber.hasPrefix("+") && phoneNumber.count > 8 else {
            showError("Inserisci un numero valido includendo il prefisso (es. +39...)")
            return
        }
        
        isLoading = true
        do {
            let verificationID = try await authManager.verifyPhoneNumber(phoneNumber)
            isLoading = false
            // Passiamo l'ID al coordinator!
            coordinator?.goToOTPVerification(verificationID: verificationID, phoneNumber: phoneNumber)
        } catch {
            isLoading = false
            showError(error.localizedDescription)
        }
    }
    
    private func showError(_ message: String) {
        self.alertMsg = message
        self.showAlert = true
    }
}
