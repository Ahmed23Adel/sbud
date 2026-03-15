//
//  UserRepository.swift
//  sbud
//
//  Created by ahmed on 25/12/2025.
// ownerProfilePicture
import Foundation
import FirebaseAuth
import FirebaseFirestore



class UserRepository: IFirebaesRepository{
    typealias T = IOtherUser
    
    let collectionPath: String = "users"
    let firebaseClient = FirebaseClient()
    let constants = UserRepositoryConstants()
    let db = Firestore.firestore()
    
    
    
    func fetch(query: any IQueryBuilder) async throws -> [any T] {
        return  []
    }
    
    func fetchById(_ id: String) async throws -> (any T)? {
        return nil
    }
    
    func fetchByIds(_ ids: [String]) async throws -> [any T]? {
        guard !ids.isEmpty else { return [] }
        return []
    }
    
    func create(_ item: any T) async throws -> String {
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
        print("10")
        let snapshot = try await db.collection("users").document(id).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: UserProfile.self)
    }
    
    func update(_ id: String, _ item: any T) async throws {
    
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
