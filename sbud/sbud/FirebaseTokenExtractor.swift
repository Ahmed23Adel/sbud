//
//  FirebaseTokenExtractor.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import FirebaseAuth

class FirebaseTokenExtractor: @unchecked Sendable {

    @Sendable func getIDToken() async -> String {
       guard let user = Auth.auth().currentUser else {
           return ""
       }
        print("🔑 [DEBUG] FirebaseTokenExtractor.getIDToken uid=\(user.uid)")
        do {
            return try await FirebaseTokenProvider.shared.getToken() ?? ""
        } catch {
            return ""
        }

   }
    
    

}
