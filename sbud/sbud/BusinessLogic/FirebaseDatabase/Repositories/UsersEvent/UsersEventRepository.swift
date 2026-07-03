//
//  MyEventRepository.swift
//  sbud
//
//  Created by ahmed on 30/04/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UsersEventRepository: IFirebaesRepository{
    
    
    typealias T = UsersEvent
    typealias Constants = UsersEventRepositoryConstants
    
    let collectionPath = "Events"
    let firebaseClient = FirebaseClient()
    let constants = UsersEventRepositoryConstants()
    let db = Firestore.firestore()
    
    func delete(_ id: String) async throws {
        
    }
    
    func initQueryBuilderObject() -> any IQueryBuilder {
        QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
        
    }
    
    
    func fetch(query: any IQueryBuilder) async throws -> [UsersEvent] {
        let queryRef = query.build()
        let snapshot = try await queryRef.getDocuments()
        let documents = snapshot.documents
        
        let userEvents = documents.compactMap { doc -> UsersEvent? in
            let data = doc.data()
            let id = doc.documentID
            guard let activityType = data["activityType"] as? String,
                  let title = data["title"] as? String,
                  let eventImage = data["eventImage"] as? String,
                  let status = data["status"] as? String else {
                return nil
            }
            let isPublic = data["isPublic"] as? Bool ?? true
            return UsersEvent(
                activityType: ActivityType(rawValue: activityType) ?? .running,
                title: title,
                eventImage: eventImage,
                status: UsersEventStatus(rawValue: status) ?? .proposed,
                eventId: id,
                isPublic: isPublic)
        }
        
        return userEvents
    }
    
    func fetchById(_ id: String) async throws -> UsersEvent? {
        
        return nil
    }
    
    func fetchByIds(_ ids: [String]) async throws -> [UsersEvent]? {
        return []
    }
    
    func create(_ item: UsersEvent) async throws -> String {
        ""
    }
    
    func update(_ id: String, _ item: UsersEvent) async throws {
        
    }
    
    
    
    
    
}
