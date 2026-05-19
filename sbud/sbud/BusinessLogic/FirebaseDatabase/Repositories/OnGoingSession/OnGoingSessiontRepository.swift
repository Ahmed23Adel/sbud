//
//  OnGoingSessiontRepository.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class OnGoingSessionRepository: IFirebaesRepository{
    typealias T = OnGoingSession
    typealias Constants = OnGoindSessionRepositoryConstants
    
    let collectionPath = "OnGoingSession"
    let firebaseClient = FirebaseClient()
    let constants = OnGoindSessionRepositoryConstants()
    let db = Firestore.firestore()
    
    
    func fetch(query: any IQueryBuilder) async throws -> [OnGoingSession] {
        let queryRef = query.build()
        let snapshot = try await queryRef.getDocuments()
        let documents = snapshot.documents
        
        let sessions = documents.compactMap { doc in
            try? doc.data(as: OnGoingSession.self)
        }
        
        return sessions
    }
    
    func fetchById(_ id: String) async throws -> OnGoingSession? {
        return nil
    }
    
    func fetchByIds(_ ids: [String]) async throws -> [OnGoingSession]? {
        return []
    }
    
    @discardableResult
    func create(_ item: OnGoingSession) async throws -> String {
        print("trying to create")
        let docRef = db.collection(collectionPath).document()
        try docRef.setData(from: item)
        return docRef.documentID
    }
    
    func update(_ id: String, _ item: OnGoingSession) async throws {
        
    }
    
    func delete(_ id: String) async throws {
        try await db.collection(collectionPath).document(id).delete()
    }
    
    func deleteByEventId(_ eventId: String) async throws {
        let snapshot = try await db.collection(collectionPath)
            .whereField("eventId", isEqualTo: eventId)
            .getDocuments()

        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    func initQueryBuilderObject() -> any IQueryBuilder {
        QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
    }
    
    
    
}
    
