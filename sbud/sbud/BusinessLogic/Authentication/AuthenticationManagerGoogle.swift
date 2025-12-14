//
//  AuthenticationManagerGoogle.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation
import Combine
import FirebaseAuth
import GoogleSignIn

class AuthenticationManagerGoogle: IAuthenticationManager {
    @Published var isSignedIn: Bool = false
    @Published var currentUser: FirebaseAuth.User?
    @Published var isLoading: Bool = true

    private let googleSignUpManager = GoogleSignUpManager()
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    init() {
        checkAuthState()
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.updateUserState(user: user)
            }
        }
    }

    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }

    private func checkAuthState() {
        if let user  = Auth.auth().currentUser {
            updateUserState(user: user)
        }
        finishLoading()
    }

    private func updateUserState(user: User?) {
        currentUser = user
        isSignedIn = user != nil

        DispatchQueue.main.async {
            AuthenticationManager.shared.currentUser = user
            AuthenticationManager.shared.isSignedIn = user != nil
            AuthenticationManager.shared.isLoading = false

            if user != nil {
                AuthenticationManager.shared.signInMethod = AuthenticationConstants.methodGoogle
            }
        }
        finishLoading()
    }

    private func finishLoading() {
        isLoading = false
    }

    func signUp() async throws {
        try await googleSignUpManager.signUpWithGoogle()

    }

    func signIn() async throws {
        try await googleSignUpManager.signUpWithGoogle()
    }

    func signOut() async throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        AuthenticationManager.shared.signInMethod = AuthenticationConstants.methodUnknown
        AuthenticationManager.shared.isSignedIn = false
        AuthenticationManager.shared.currentUser = nil
        AuthenticationManager.shared.isLoading = false

    }

    func checkAuthStatus() -> Bool {
        if let user  = Auth.auth().currentUser {
            updateUserState(user: user)
            finishLoading()
            return true
        } else {
            finishLoading()
            return false
        }

    }

}
