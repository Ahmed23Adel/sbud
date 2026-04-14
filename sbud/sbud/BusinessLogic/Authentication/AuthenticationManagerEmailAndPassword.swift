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
    @Published var currentUser: User?
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
        await propagateToShared(firebaseUser: result.user, method: .email)

    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        await propagateToShared(firebaseUser: result.user, method: .email)
    }

    func signOut() async throws {
        try Auth.auth().signOut()
        await MainActor.run {
            self.currentUser = nil
            self.isSignedIn = false
            AuthenticationManager.shared.currentUser = nil
            AuthenticationManager.shared.isSignedIn = false
            AuthenticationManager.shared.isLoading = false
            AuthenticationManager.shared.signInMethod = AuthType.unknown.rawValue
        }
    }

    func checkAuthStatus() -> Bool {
        guard let firebaseUser = Auth.auth().currentUser else { return false }
        Task {
            await propagateToShared(firebaseUser: firebaseUser, method: .email)
        }
        return true
    }
    
    func sendVerificationEmail() {
        // Assicuriamoci che ci sia un utente loggato
        guard let user = Auth.auth().currentUser else {
            print("Nessun utente attualmente loggato.")
            return
        }
        
        user.sendEmailVerification { error in
            if let error = error {
                print("Errore durante l'invio dell'email di verifica: \(error.localizedDescription)")
                // Qui puoi aggiornare lo stato della UI per mostrare un messaggio di errore
            } else {
                print("Email di verifica inviata con successo!")
                // Qui puoi avvisare l'utente di controllare la casella di posta
            }
        }
    }
    

    func reloadUser() async throws {
        guard let user = Auth.auth().currentUser else { return }
        
        
        try await user.reload()
        
        
        guard let updatedUser = Auth.auth().currentUser else { return }
        await propagateToShared(firebaseUser: updatedUser, method: .email)
    }
    
    @MainActor
    private func propagateToShared(firebaseUser: FirebaseAuth.User, method: AuthType) async {
        await AuthenticationManager.shared.setCurrentUser(from: firebaseUser)
        AuthenticationManager.shared.signInMethod = method.rawValue
        // Mirror state locally too, in case anything observes this manager directly
        self.currentUser = AuthenticationManager.shared.currentUser
        self.isSignedIn = true
        self.isLoading = false
    }

}
