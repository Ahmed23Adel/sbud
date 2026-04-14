//
//  AuthenticationManagerPhone.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 14/04/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class AuthenticationManagerPhone: IAuthenticationManager {
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User?
    
    static let shared = AuthenticationManagerPhone()
    
    private init() {}
    
    // Metodi protocollo base non supportati direttamente senza argomenti
    func signIn() async throws { throw AuthError.unauthorizedAction }
    func signUp() async throws { throw AuthError.unauthorizedAction }
    func signIn(email: String, password: String) async throws { throw AuthError.unauthorizedAction }
    func signUp(email: String, password: String) async throws { throw AuthError.unauthorizedAction }
    
    func signOut() async throws {
        try Auth.auth().signOut()
        // Pulisci lo stato condiviso come fai nel manager Email
    }
    
    func checkAuthStatus() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    // MARK: - Metodi specifici per il Telefono
    
    /// 1. Richiede l'invio dell'SMS e restituisce il Verification ID
    func verifyPhoneNumber(_ phoneNumber: String) async throws -> String {
        // uiDelegate nil usa le impostazioni predefinite (o reCAPTCHA se necessario)
        return try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)
    }
    
    @MainActor
    private func propagateToShared(firebaseUser: FirebaseAuth.User, method: AuthType) async {
        await AuthenticationManager.shared.setCurrentUser(from: firebaseUser)
        AuthenticationManager.shared.signInMethod = method.rawValue
        self.currentUser = AuthenticationManager.shared.currentUser
        self.isSignedIn = true
    }
    
    func signInWithCode(verificationID: String, verificationCode: String) async throws -> Bool {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        let result = try await Auth.auth().signIn(with: credential)
        let firebaseUser = result.user
        
        
        let userExists = try await checkIfUserExistsInFirestore(uid: firebaseUser.uid)
        
        await propagateToShared(firebaseUser: firebaseUser, method: .phone)
        
        return userExists 
    }

    private func checkIfUserExistsInFirestore(uid: String) async throws -> Bool {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        return snapshot.exists
    }
}
