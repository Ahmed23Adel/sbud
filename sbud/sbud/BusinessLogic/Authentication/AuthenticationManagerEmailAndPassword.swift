//
//  AuthenticationManagerEmailAndPassword.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation
import Combine
import FirebaseAuth

class AuthenticationManagerEmailAndPassword: IAuthenticationManager {
    @Published var isSignedIn: Bool = false
    @Published var currentUser: FirebaseAuth.User?
    @Published var isLoading: Bool = true
    static let shared = AuthenticationManagerEmailAndPassword()

    init() {
    }

    func signIn() async throws {
        throw AuthError.unauthorizedAction
    }

    func signUp() async throws {
        throw AuthError.unauthorizedAction
    }

    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.currentUser = result.user
        self.updateUserState(user: currentUser, methodUsed: .email)

    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.currentUser = result.user
        self.updateUserState(user: currentUser, methodUsed: .email)
    }

    func signOut() throws {
        self.currentUser = nil
        try? Auth.auth().signOut()
        AuthenticationManager.shared.signInMethod = AuthType.unknown.rawValue
        AuthenticationManager.shared.isSignedIn = false
        AuthenticationManager.shared.currentUser = nil
        AuthenticationManager.shared.isLoading = false
    }
    
    func sendVerificationEmail() {
    //is logged?
    guard let user = Auth.auth().currentUser else {
        print("Nessun utente attualmente loggato.")
        return
    }
    //send verification mail
        user.sendEmailVerification { error in
            if let error = error {
                print("Error during verification mail: \(error.localizedDescription)")
                
            } else {
                print("Verification mail is sent")
                
            }
        }
    }
    
    func reloadUser() async throws {
        guard let user = Auth.auth().currentUser else { return }
        
        
        try await user.reload()
        
        self.updateUserState(user: currentUser, methodUsed: .email)
    }

    func checkAuthStatus() -> Bool {
        if let user  = Auth.auth().currentUser {
            updateUserState(user: user, methodUsed: .email)
            return true
        } else {
            return false
        }
    }

}
