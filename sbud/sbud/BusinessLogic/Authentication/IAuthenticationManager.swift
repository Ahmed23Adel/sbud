//
//  IAuthenticationManager.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation
import Combine
import FirebaseAuth

protocol IAuthenticationManager: ObservableObject {
    var isSignedIn: Bool { get set}
    var currentUser: User? { get set}

    func checkAuthStatus() -> Bool
    func signIn() async throws
    func signUp() async throws
    func signOut() async throws

    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws

}

extension IAuthenticationManager {

    func updateUserState(user: User?, methodUsed: AuthType) {
        currentUser = user
        isSignedIn = user != nil

        DispatchQueue.main.async {
            AuthenticationManager.shared.currentUser = user
            AuthenticationManager.shared.isSignedIn = user != nil
            AuthenticationManager.shared.isLoading = false

            if user != nil {
                AuthenticationManager.shared.signInMethod = methodUsed.rawValue
            }
        }
    }
}
