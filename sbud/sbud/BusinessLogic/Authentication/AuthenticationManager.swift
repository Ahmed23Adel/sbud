//
//  AuthenticationManager.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//
import Combine
import FirebaseAuth
import SwiftUI

class AuthenticationManager: IAuthenticationManager {
    static let shared = AuthenticationManager()
    @Published var isSignedIn: Bool = false
    @Published var currentUser: FirebaseAuth.User?
    @Published var isLoading: Bool = true

    @AppStorage(AppStorageConstants.signInMehtod) var signInMethod = AuthenticationConstants.methodUnknown
    private var signInMethodManager: (any IAuthenticationManager)?

    init() {
        if signInMethod == AuthenticationConstants.methodUnknown {
            Task { @MainActor in
                setUserLoggedOut()
            }

        } else if signInMethod == AuthenticationConstants.methodGoogle {
            signInMethodManager = AuthenticationManagerGoogle()

        } else if signInMethod == AuthenticationConstants.methodEmailAndPassword {
            signInMethodManager = AuthenticationManagerEmailAndPassword()
        }
    }
    func setAuthTypeGoogle() {
        signInMethodManager = AuthenticationManagerGoogle()
    }

    func setAuthTypeEmailAndPassword() {
        signInMethodManager = AuthenticationManagerEmailAndPassword()
    }
    @MainActor
    private func setUserLoggedOut() {
        Task { @MainActor in
            self.isSignedIn = false
            self.currentUser = nil
            self.isLoading = false
        }
    }

    func signUp() async throws {
        try await signInMethodManager?.signUp()
    }

    func signIn() async throws {
        try await signInMethodManager?.signIn()
    }

    func signOut() async throws {
        try await signInMethodManager?.signOut()
        signInMethod = AuthenticationConstants.methodUnknown
        signInMethodManager = nil

    }

    func checkAuthStatus() -> Bool {
        guard let signInMethodManager else {
            setUserLoggedOut()
            return false
        }
        return signInMethodManager.checkAuthStatus()
    }

}
