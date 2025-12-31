//
//  AuthenticationManager.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//
import Combine
import FirebaseAuth
import SwiftUI

class AuthenticationManager: IAuthenticationManager{
    static let shared = AuthenticationManager()
    @Published var isSignedIn: Bool = false
    @Published var currentUser: FirebaseAuth.User?
    @Published var isLoading: Bool = true
    
    @AppStorage(AppStorageConstants.SIGN_IN_METHOD) var signInMethod = AuthenticationConstants.METHOD_UNKNOWN
    private var signInMethodManager: (any IAuthenticationManager)?
    
    init(){
        if signInMethod == AuthenticationConstants.METHOD_UNKNOWN{
            Task { @MainActor in
                setUserLoggedOut()
            }
            
            
        } else if signInMethod == AuthType.google.rawValue{
            signInMethodManager = AuthenticationManagerGoogle()
            
        } else if signInMethod == AuthType.email.rawValue{
            signInMethodManager = AuthenticationManagerEmailAndPassword()
        }
    }
    func setAuthTypeGoogle(){
        signInMethodManager = AuthenticationManagerGoogle()
    }
    
    func setAuthTypeEmailAndPassword(){
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
    
    // MARK: Google sign in
    func signUp() async throws {
        try await signInMethodManager?.signUp()
    }
    
    func signIn() async throws {
        try await signInMethodManager?.signIn()
    }
    
    // MARK: Email sing in
    func signIn(email: String, password: String) async throws {
        try await signInMethodManager?.signIn(email: email, password: password)
    }
    
    func signUp(email: String, password: String) async throws {
        try await signInMethodManager?.signUp(email: email, password: password)
    }
    
    // MARK: Sign out
    func signOut() async throws {
        try await signInMethodManager?.signOut()
        signInMethod = AuthenticationConstants.METHOD_UNKNOWN
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
