//
//  SignInViewModel.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation
import Combine
import FirebaseAnalytics

@MainActor
class SignInViewModel: ObservableObject {

    private let authManager: any IAuthOrchestrator
    @Published var showAlert = false
    @Published var alertMsg = ""
    var coordinator: MainCoordinator?
    @Published var email = ""
    @Published var password = ""
    @Published var isSigningIn = false
    @Published var showPassword = false
    @Published var isLoading = false

    init(authManager: any IAuthOrchestrator = AuthenticationManager.shared) {
        self.authManager = authManager
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "SignIn"])
    }

    func setCoordinator(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }

    // MARK: auth Google
    func signUpWithGoogle() async {
        authManager.setAuthTypeGoogle()
        do {
            try await authManager.signIn()
            coordinator?.coordinatorDidCompleteSignIn()
        } catch {
            showAlert = true
            alertMsg = "Problem with user registration, please try again"
        }
    }

    // MARK: auth Email
    func singInWithEmail() async throws {
        if !InputValidators().validateInputs(
            email: email,
            password: password,
            emailAlertFunction: showAlertEmail,
            passwordAlertFunction: showAlertPassword) { return }

        startLoading()
        isSigningIn = true
        authManager.setAuthTypeEmailAndPassword()
        do {
            try await authManager.signIn(email: email, password: password)
            isSigningIn = false
            stopLoading()
            coordinator?.coordinatorDidCompleteSignIn()
        } catch {
            stopLoading()
            isSigningIn = false
            showAlert = true
            alertMsg = "Email or password are incorrect, please try again"
        }
    }

    func goToSignUp() {
        coordinator?.goToSignUp()
    }

    private func showAlertEmail() {
        alertMsg = "Insert a valid email (ex. name@mail.com)"
        showAlert = true
    }

    private func showAlertPassword() {
        alertMsg = "Password must contain at least 6 characters, 1 letter, and 1 number at least"
        showAlert = true
    }

    // MARK: view helpers
    private func startLoading() {
        self.isLoading = true
    }

    private func stopLoading() {
        self.isLoading = false
    }

    func forgotPassword() async {
        guard !email.isEmpty else {
            showAlert = true
            alertMsg = "Please enter your email address first"
            return
        }

        startLoading()
        do {
            try await authManager.sendPasswordReset(email: email)
            stopLoading()
            showAlert = true
            alertMsg = "Password reset email sent! Check your inbox."
        } catch {
            stopLoading()
            showAlert = true
            alertMsg = "Could not send reset email. Make sure the address is correct."
        }
    }
}
