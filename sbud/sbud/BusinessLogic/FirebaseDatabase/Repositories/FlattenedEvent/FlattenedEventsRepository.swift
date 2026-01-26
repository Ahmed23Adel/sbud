//
//  FlattenedEventsRepository.swift
//  sbud
//
//  Created by ahmed on 24/01/2026.
//

import Foundation
import FirebaseFirestore

class FlattenedEventsRepository: IFirebaesRepository{
    typealias T = FlattenedEvent
    let collectionPath: String = "flattenedEvents"
    let firebaseClient = FirebaseClient()
    var constants =  FlattenedEventConstants()
    
    func fetch(query: any IQueryBuilder) async throws -> [FlattenedEvent] {
        let queryRef = query.build()
        let snapshot = try await queryRef.getDocuments()
        let documents = snapshot.documents
        let flattenedEvents = documents.compactMap { doc ->  FlattenedEvent? in
            let docId = doc.documentID
            let data = doc.data()
            guard let eventId = data[constants.eventId] as? String,
                  let dateLocationId = data[constants.dateLocationId] as? String,
                  let createdAt = data[constants.createdAt] as? Date,
                  let eventImage = data[constants.eventImage] as? String,
                  let activityType = data[constants.activityType] as? String,
                  let isDateConfirmed = data[constants.isDateConfirmed] as? Bool,
                  let isLocationConfirmed = data[constants.isLocationConfirmed] as? Bool,
                  let isPublic = data[constants.isPublic] as? Bool,
                  let geohash = data[constants.geohash] as? String,
                  let geoPoint = data[constants.geopoint] as? GeoPoint else {
                return nil
            }
            
            return FlattenedEvent(id: docId,
                                  eventId: eventId,
                                  dateLocationId: dateLocationId,
                                  activityType: ActivityTypeCreatorFromString(activityType).create(),
                                  createdAt: createdAt,
                                  eventImage: eventImage,
                                  isDateConfirmed: isDateConfirmed,
                                  isLocationConfirmed: isLocationConfirmed,
                                  isPublic: isPublic,
                                  geohash: geohash,
                                  geoPoint: geoPoint)
        }
        return flattenedEvents
    }
    
    func fetchById(_ id: String) async throws -> FlattenedEvent? {
        return nil
    }
    
    func fetchByIds(_ ids: [String]) async throws -> [FlattenedEvent]? {
        return nil
    }
    
    func create(_ item: FlattenedEvent) async throws -> String {
        return ""
    }
    
    func update(_ id: String, _ item: FlattenedEvent) async throws {
        
    }
    
    func delete(_ id: String) async throws {
        
    }
    
    func initQueryBuilderObject() -> any IQueryBuilder {
        return QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
    }
    
    
}
