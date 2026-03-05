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
    @Published var currentUser: User?
    @Published var isLoading: Bool = true
    private let googleSignUpManager: IGoogleSignUpManager
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    init(googleSignUpManager: IGoogleSignUpManager = GoogleSignUpManager()) {
        self.googleSignUpManager = googleSignUpManager
        checkAuthState()
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self, let firebaseUser else { return }
            Task { @MainActor in
                await self.propagateToShared(firebaseUser: firebaseUser, method: .google)
            }
        }
    }

    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }

    // MARK: Checking state
    private func checkAuthState() {
        guard let firebaseUser = Auth.auth().currentUser else { return }
        Task { @MainActor in
            await propagateToShared(firebaseUser: firebaseUser, method: .google)
        }
    }

    // MARK: Google sign in/up
    func signUp() async throws {
        try await googleSignUpManager.signUpWithGoogle()
        if let firebaseUser = Auth.auth().currentUser {
            await propagateToShared(firebaseUser: firebaseUser, method: .google)
        }
    }

    func signIn() async throws {
        try await googleSignUpManager.signUpWithGoogle()
        if let firebaseUser = Auth.auth().currentUser {
            await propagateToShared(firebaseUser: firebaseUser, method: .google)
        }
    }

    // MARK: - Email sign in / up (unsupported)
    func signIn(email: String, password: String) async throws {
        throw AuthError.unauthorizedAction
    }

    func signUp(email: String, password: String) async throws {
        throw AuthError.unauthorizedAction
    }

    // MARK: - Sign out
    func signOut() async throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        await MainActor.run {
            self.currentUser = nil
            self.isSignedIn = false
            AuthenticationManager.shared.currentUser = nil
            AuthenticationManager.shared.isSignedIn = false
            AuthenticationManager.shared.isLoading = false
            AuthenticationManager.shared.signInMethod = AuthType.unknown.rawValue
        }
    }

    func checkAuthStatus() -> Bool {
        guard let firebaseUser = Auth.auth().currentUser else { return false }
        Task {
            await propagateToShared(firebaseUser: firebaseUser, method: .google)
        }
        return true
    }


    @MainActor
    private func propagateToShared(firebaseUser: FirebaseAuth.User, method: AuthType) async {
        await AuthenticationManager.shared.setCurrentUser(from: firebaseUser)
        AuthenticationManager.shared.signInMethod = method.rawValue
        // Mirror state locally in case anything observes this manager directly
        self.currentUser = AuthenticationManager.shared.currentUser
        self.isSignedIn = true
        self.isLoading = false
    }
}
