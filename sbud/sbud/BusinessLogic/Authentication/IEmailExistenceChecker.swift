//
//  IEmailExistenceChecker.swift
//  sbud
//

import Foundation
import FirebaseFirestore

protocol IEmailExistenceChecker {
    func isEmailTaken(_ email: String) async throws -> Bool
}

struct FirestoreEmailExistenceChecker: IEmailExistenceChecker {
    func isEmailTaken(_ email: String) async throws -> Bool {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments()
        return !snapshot.isEmpty
    }
}
