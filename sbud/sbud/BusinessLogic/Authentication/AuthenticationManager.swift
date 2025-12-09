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
    
    init(){
        checkAuthState()
    }
    
    private func checkAuthState(){
        if let user  = Auth.auth().currentUser{
            updateUserState(user: user)
        }
        FinishLoading()
    }
    
    private func updateUserState(user: User){
        currentUser = user
        FinishLoading()
    }
    
    private func FinishLoading(){
        isLoading = false
    }
}
