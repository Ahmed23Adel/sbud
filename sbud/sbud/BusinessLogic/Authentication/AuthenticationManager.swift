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
            setUserLoggedOut()
            
        } else if signInMethod == AuthenticationConstants.METHOD_GOOGLE{
            signInMethodManager = AuthenticationManagerGoogle()
            
        } else if signInMethod == AuthenticationConstants.METHOD_EmailAndPassword{
            signInMethodManager = AuthenticationManagerEmailAndPassword()
        }
    }
    func setAuthTypeGoogle(){
        signInMethodManager = AuthenticationManagerGoogle()
    }
    
    func setAuthTypeEmailAndPassword(){
        signInMethodManager = AuthenticationManagerEmailAndPassword()
    }
    
    private func setUserLoggedOut(){
        isSignedIn = false
        currentUser = nil
        isLoading = false
    }
    func signUp() async throws {
        try await signInMethodManager?.signUp()
    }
    
    func signIn() async throws {
        try await signInMethodManager?.signIn()
    }
    
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
