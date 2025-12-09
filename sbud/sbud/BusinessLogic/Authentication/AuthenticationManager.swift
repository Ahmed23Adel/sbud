//
//  AuthenticationManager.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation
import SwiftUI
import Combine
import GoogleSignIn
import FirebaseAuth

class AuthenticationManager: ObservableObject{
    static let shared = AuthenticationManager()
    
    
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = true
    
    private let googleSignUpManager = GoogleSignUpManager()
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init(){
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
    private func checkAuthState(){
        if let user  = Auth.auth().currentUser{
            updateUserState(user: user)
        }
        FinishLoading()
    }
    
    private func updateUserState(user: User?){
        currentUser = user
        isSignedIn = user != nil
        FinishLoading()
    }
    
    private func FinishLoading(){
        isLoading = false
    }
    
    
    func signUpWithGoogle() async throws{
        try await googleSignUpManager.signUpWithGoogle()
    }
    
    func signOut() throws{
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }
}
