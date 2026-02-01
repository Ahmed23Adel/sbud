//
//  FirebaseTokenExtractor.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import FirebaseAuth

class FirebaseTokenExtractor: @unchecked Sendable{
    
    func getIDToken() async -> String {
       guard let user = Auth.auth().currentUser else {
           return ""
       }
        do {
            let idToken = try await user.getIDToken()
            return idToken
        } catch {
            print("not found")
            return ""
        }
        
   }
    
}
