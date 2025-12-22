//
//  IAuthenticationManager.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation
import Combine
import FirebaseAuth

protocol IAuthenticationManager: ObservableObject{
    var isSignedIn: Bool { get set}
    var currentUser: User? { get set}
    var isLoading: Bool { get set}
    
    func checkAuthStatus () -> Bool
    func signIn() async throws
    func signUp() async throws
    func signOut() async throws
    
}
