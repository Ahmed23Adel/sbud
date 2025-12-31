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

class AuthenticationManagerGoogle: IAuthenticationManager{
    @Published var isSignedIn: Bool = false
    @Published var currentUser: FirebaseAuth.User?
    private let googleSignUpManager: IGoogleSignUpManager
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init(googleSignUpManager: IGoogleSignUpManager = GoogleSignUpManager()){
        self.googleSignUpManager = googleSignUpManager
        checkAuthState()
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.updateUserState(user: user, methodUsed: .google)
            }
        }
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    // MARK: Checking state
    private func checkAuthState(){
        if let user  = Auth.auth().currentUser{
            updateUserState(user: user, methodUsed: .google)
        }
    }
            
    // MARK: Google sign in/up
    func signUp() async throws  {
        try await googleSignUpManager.signUpWithGoogle()
        
    }
    
    func signIn() async throws {
        try await googleSignUpManager.signUpWithGoogle()
    }
    
    // MARK: Email sign in/up
    func signIn(email: String, password: String) async throws {
        throw AuthError.unauthorizedAction
    }
    
    func signUp(email: String, password: String) async throws {
        throw AuthError.unauthorizedAction
    }
    
    // MARK: sign  out
    func signOut() async throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        AuthenticationManager.shared.signInMethod = AuthenticationConstants.METHOD_UNKNOWN
        AuthenticationManager.shared.isSignedIn = false
        AuthenticationManager.shared.currentUser = nil
        AuthenticationManager.shared.isLoading = false
        
    }
    
    func checkAuthStatus() -> Bool {
        if let user  = Auth.auth().currentUser{
            updateUserState(user: user, methodUsed: .google)
            return true
        } else{
            return false
        }
    }
    
    
    
}
