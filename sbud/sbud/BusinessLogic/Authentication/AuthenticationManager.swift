//
//  AuthenticationManager.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//
import Combine
import FirebaseAuth
import SwiftUI
import FirebaseFirestore

class AuthenticationManager: IAuthenticationManager {
    static let shared = AuthenticationManager()
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = true

    @AppStorage(AppStorageConstants.signInMethod) var signInMethod = AuthType.unknown.rawValue
    private var signInMethodManager: (any IAuthenticationManager)?

    init() {
        if signInMethod == AuthType.unknown.rawValue {
            Task { @MainActor in
                setUserLoggedOut()
            }

        } else if signInMethod == AuthType.google.rawValue {
            signInMethodManager = AuthenticationManagerGoogle()

        } else if signInMethod == AuthType.email.rawValue {
            signInMethodManager = AuthenticationManagerEmailAndPassword()
        }
    }
    func setAuthTypeGoogle() {
        signInMethodManager = AuthenticationManagerGoogle()
    }

    func setAuthTypeEmailAndPassword() {
        signInMethodManager = AuthenticationManagerEmailAndPassword()
    }
    @MainActor
    private func setUserLoggedOut() {
        Task { @MainActor in
            self.isSignedIn = false
            self.currentUser = nil
            self.isLoading = false
        }
    }
    
    @MainActor
    func setCurrentUser(from firebaseUser: FirebaseAuth.User) async {
        // 1. Try to load a full profile from Firestore
        if let user = try? await fetchUserFromFirestore(uid: firebaseUser.uid) {
            self.currentUser = user
        } else {
            let newUser = User(
                uid: firebaseUser.uid,
                username: firebaseUser.displayName ?? firebaseUser.email ?? "Unknown",
                email: firebaseUser.email ?? "",
                profileImageUrl: firebaseUser.photoURL?.absoluteString
            )
            try? await saveUserToFirestore(newUser)
            self.currentUser = newUser
        }
        self.isSignedIn = true
        self.isLoading = false
    }
    
    private func saveUserToFirestore(_ user: User) async throws {
        guard let uid = user.uid else { return }
        try Firestore.firestore()
            .collection("users")
            .document(uid)
            .setData(from: user)
    }
    
    private func fetchUserFromFirestore(uid: String) async throws -> User? {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument()
        return try snapshot.data(as: User.self)
    }

    // MARK: Google sign in
    func signUp() async throws {
        try await signInMethodManager?.signUp()
        if let firebaseUser = Auth.auth().currentUser {
            await setCurrentUser(from: firebaseUser)
        }
    }

    func signIn() async throws {
        try await signInMethodManager?.signIn()
        if let firebaseUser = Auth.auth().currentUser {
            await setCurrentUser(from: firebaseUser)
        }
    }

    // MARK: Email sing in
    func signIn(email: String, password: String) async throws {
        try await signInMethodManager?.signIn(email: email, password: password)
        if let firebaseUser = Auth.auth().currentUser {
            await setCurrentUser(from: firebaseUser)
        }
    }

    func signUp(email: String, password: String) async throws {
        try await signInMethodManager?.signUp(email: email, password: password)
        if let firebaseUser = Auth.auth().currentUser {
            await setCurrentUser(from: firebaseUser)
        }
    }

    // MARK: Sign out
    func signOut() async throws {
        try await signInMethodManager?.signOut()
        signInMethod = AuthType.unknown.rawValue
        signInMethodManager = nil
        await MainActor.run { setUserLoggedOut() }
    }

    func checkAuthStatus() -> Bool {
        guard let signInMethodManager else {
            setUserLoggedOut()
            return false
        }
        return signInMethodManager.checkAuthStatus()
    }

}
