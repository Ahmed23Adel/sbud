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

    init() {

    }

    func signUp() throws {

    }

    func signIn() throws {

    }

    func signOut() throws {

    }

    func checkAuthStatus() -> Bool {
        return true
    }

}
