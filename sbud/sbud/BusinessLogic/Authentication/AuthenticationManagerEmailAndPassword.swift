//
//  AuthenticationManagerEmailAndPassword.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation
import Combine
import FirebaseAuth

class AuthenticationManagerEmailAndPassword: IAuthenticationManager{
    
    @Published var isSignedIn: Bool = false
    @Published var currentUser: FirebaseAuth.User?
    @Published var isLoading: Bool = true
    
    static let shared = AuthenticationManagerEmailAndPassword()
    
    init(){
        
    }
    
    func signIn() async throws {
        
    }
    
    func signUp() async throws {
        
    }
    
    @MainActor
    func signUp(email: String, password: String, username: String) async throws {
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.currentUser = result.user
            
        } catch {
            print("DEBUG: Failed to create user with error: \(error.localizedDescription)")
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.currentUser = result.user
        } catch {
            print("DEBUG: Login failed \(error.localizedDescription)")
        }
    }
    
    func signOut() throws {
        self.currentUser = nil
        try? Auth.auth().signOut()
    }
    
    func checkAuthStatus() -> Bool {
        return true
    }
}
