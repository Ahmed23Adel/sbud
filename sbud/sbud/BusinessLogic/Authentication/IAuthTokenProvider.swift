//
//  IAuthTokenProvider.swift
//  sbud
//

import Foundation

protocol IAuthTokenProvider {
    func getToken() async throws -> String
}

struct FirebaseAuthTokenProvider: IAuthTokenProvider {
    func getToken() async throws -> String {
        guard let token = try await BasicAuth.getTokenId() else {
            throw StoriesError.unauthenticated
        }
        return token
    }
}
