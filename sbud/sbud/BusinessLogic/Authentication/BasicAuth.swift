//
//  BasicAuth.swift
//  sbud
//
//  Created by ahmed on 14/04/2026.
//

import Foundation
import FirebaseAuth

class BasicAuth {
    
    static func getTokenId() async throws -> String? {
        guard let currentUser = Auth.auth().currentUser else{
            return nil
        }
        let token = try await currentUser.getIDToken()
        return token
    }
}
