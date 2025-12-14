//
//  GoogleSignUpManager.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation
import FirebaseCore
import GoogleSignIn
import UIKit
import FirebaseAuth

class GoogleSignUpManager {

    func signUpWithGoogle() async throws {
        let clientId = try getClientID()
        _ = getGIDSignInConfigured(clientID: clientId)
        let windowForLogin = try getWindowForLogin()
        try await performSignUpUsingGoogle(rootViewController: windowForLogin)
    }

    private func getClientID() throws -> String {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw GoogleSignUpError.missingClientID
        }
        return clientID
    }

    private func getGIDSignInConfigured(clientID: String) -> GIDSignIn {
        let config = GIDConfiguration(clientID: clientID)
        let gidSignIn = GIDSignIn.sharedInstance
        gidSignIn.configuration = config
        return gidSignIn
    }

    private func getWindowForLogin() throws -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw GoogleSignUpError.cannotGetRootViewController
        }
        return rootViewController
    }

    private func performSignUpUsingGoogle(rootViewController: UIViewController) async throws {
        let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let user = userAuthentication.user
        let (idToken, accessToken) = try getIdAndAccessToken(user: user)
        let credentials = GoogleAuthProvider.credential(
            withIDToken: idToken.tokenString,
            accessToken: accessToken.tokenString)
        _ = try await Auth.auth().signIn(with: credentials)

    }

    private func getIdAndAccessToken(user: GIDGoogleUser) throws -> (GIDToken, GIDToken) {
        guard let idToken  = user.idToken else {
            throw GoogleSignUpError.cannotFindIdToken
        }
        return (idToken, user.accessToken)
    }

}
