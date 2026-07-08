//
//  IAuthOrchestrator.swift
//  sbud
//

import Foundation

/// Thin protocol covering everything the sign-in/sign-up ViewModels need from
/// the auth layer. Kept separate from IAuthenticationManager (which carries
/// ObservableObject) so it can be stored as `any IAuthOrchestrator` and mocked
/// in unit tests without hitting Firebase.
protocol IAuthOrchestrator {
    func setAuthTypeGoogle()
    func setAuthTypeEmailAndPassword()

    func signIn() async throws
    func signUp() async throws
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws

    func sendPasswordReset(email: String) async throws
    func sendVerificationEmail()
}
