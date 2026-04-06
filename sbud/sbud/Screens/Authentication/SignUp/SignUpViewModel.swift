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
import AdelsonValidator

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String =  ""
    @Published var emailIsValid = false // to ensure
    @Published var isLoading = false
    @Published var emailValidationFailed = false
    @Published var usernameValidationFailed = false
    @Published var isSigningUp = false
    let authManager = AuthenticationManager.shared
    @Published var showAlert = false
    @Published var alertMsg = ""
    var coordinator: MainCoordinator?
    @Published var isSigningIn = false
    @Published var showPassword = false

    init() {

    }
    func setCoordinator(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }

    // MARK: auth Google
    func signUpWithGoogle() async {
        authManager.setAuthTypeGoogle()
        do {
            try await authManager.signUp()
            coordinator?.refreshAppFlow()
        } catch {
            await MainActor.run {
                showAlert = true
                alertMsg = "Problem with user registration, please try again"
            }
        }
    }

    // MARK: auth email
    func signUpWithEmail() async throws {
        if !InputValidators().validateInputs(
            email: email,
            password: password,
            emailAlertFunction: showAlertEmail,
            passwordAlertFunction: showAlertPassword) {return}
        startLoading()
        authManager.setAuthTypeEmailAndPassword()
        isSigningUp = true
        do {
            try await authManager.signUp(email: email, password: password)
            isSigningUp = false
            stopLoading()
            coordinator?.refreshAppFlow()
        } catch {
            await MainActor.run {
                isSigningUp = false
                showAlert = true
                stopLoading()
                showAlertForEmail(error: error)
            }
        }
    }

    private func showAlertForEmail(error: Error) {
        let nsError = error as NSError

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
        showAlert = true
    }

    // MARK: Validators
    @MainActor
    func validateEmail() async throws {
        startLoading()
        self.emailValidationFailed = false

        let snapshot = try await Firestore.firestore().collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments()

        self.emailValidationFailed = !snapshot.isEmpty
        self.emailIsValid = snapshot.isEmpty
        stopLoading()

    }

    // MARK: Navigation
    func goToSignIn() {
        coordinator?.goToSignIn()
    }

    // MARK: View helpers
    private func startLoading() {
        self.isLoading = true
    }

    private func stopLoading() {
        self.isLoading = false
    }

    @MainActor
    private func showAlertEmail() {
        Task { @MainActor in
            alertMsg = "Insert a valid email (ex. name@mail.com)"
            showAlert = true
        }

    }
    @MainActor
    private func showAlertPassword() {
        Task { @MainActor in
            alertMsg = "Password must contain at least 6 characters, 1 letter, and 1 number at least"
            showAlert = true
        }
    }

}
