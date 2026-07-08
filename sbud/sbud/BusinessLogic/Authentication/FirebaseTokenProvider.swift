//
//  FirebaseTokenProvider.swift
//  sbud
//

import Foundation
import FirebaseAuth

/// Single source of truth for fetching the current user's Firebase ID token.
/// Forces a fresh token exactly once after each sign-in state change (login/logout/account switch),
/// then serves Firebase's local token cache until the next state change — avoids hitting
/// Firebase's token endpoint on every single request while still guaranteeing the very first
/// token after a login can't be a stale one left over from a previous session.
actor FirebaseTokenProvider {
    static let shared = FirebaseTokenProvider()

    private var needsForceRefresh = true
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    private init() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, _ in
            Task { await self?.markNeedsForceRefresh() }
        }
    }

    private func markNeedsForceRefresh() {
        needsForceRefresh = true
    }

    func getToken() async throws -> String? {
        guard let user = Auth.auth().currentUser else { return nil }
        let forceRefresh = needsForceRefresh
        needsForceRefresh = false
        return try await user.getIDToken(forcingRefresh: forceRefresh)
    }
}
