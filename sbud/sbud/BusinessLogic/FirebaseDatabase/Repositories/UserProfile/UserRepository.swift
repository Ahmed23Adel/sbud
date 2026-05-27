//
//  UserRepository.swift
//  sbud
//
//  Created by ahmed on 25/12/2025.
// ownerProfilePicture
import Foundation
import FirebaseAuth
import FirebaseFirestore
import OSLog


class UserRepository: IFirebaesRepository{
    
    typealias T =  UserProfile
    typealias Constants = UserRepositoryConstants
    
    //typealias T = IOtherUser
    
    let collectionPath: String = "users"
    let firebaseClient = FirebaseClient()
    let constants = UserRepositoryConstants()
    let db = Firestore.firestore()
    let logger = Logger(subsystem: "sbud", category: "UserRepository")
    
    
    func fetch(query: any IQueryBuilder) async throws -> [ T ] {
        return  []
    }
    
    func fetchById(_ id: String) async throws -> (T)? {
        return nil
    }
    
    func fetchByIds(_ ids: [String]) async throws -> [T]? {
        guard !ids.isEmpty else { return [] }
        return []
    }
    
    func create(_ item: T) async throws -> String {
        return ""
    }
    
    func save(_ profile: UserProfile) async throws -> String? {
        guard let user = Auth.auth().currentUser else {
            return "User couldnot find."
        }
        do {
            try db.collection("users").document(user.uid).setData(from: profile, merge: true)
            return nil
        } catch {   return error.localizedDescription   }
    }
    
    func fetchProfile(_ id: String) async throws -> UserProfile? {
        logger.info("id: \(id)")
        let snapshot = try await db.collection("users").document(id).getDocument()
        guard snapshot.exists else { return nil }

        do {
            let profile = try snapshot.data(as: UserProfile.self)
            logger.info("User profile fetched: \(profile)")
            return profile
        } catch {
            print("fetchProfile decode error:", error)
            print("raw firestore data:", snapshot.data() ?? [:])
            throw error
        }
    }
    
    func update(_ id: String, _ item: T) async throws {
    
    }
    
    
    func addFeedback(for targetUserId: String, tag: String, voterId: String) async throws {
        try await db.collection(collectionPath).document(targetUserId).updateData([
            // arrayUnion aggiunge l'elemento SOLO se non è già presente
            "feedbackVoters.\(tag)": FieldValue.arrayUnion([voterId])
        ])
    }
    
    func updateUserProfileFields(uid: String, fields: [String: Any]) async throws {
        try await db.collection("users").document(uid).setData(fields, merge: true)
    }
        
    func delete(_ id: String) async throws {
    }
    
    func initQueryBuilderObject() -> any IQueryBuilder {
        QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
    }
}
