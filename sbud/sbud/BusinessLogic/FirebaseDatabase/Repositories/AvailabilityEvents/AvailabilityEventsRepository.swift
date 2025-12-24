//
//  AvailabilityEventsRepository.swift
//  sbud
//
//  Created by ahmed on 24/12/2025.
//

import Foundation
import FirebaseFirestore

class AvailabilityEventsRepository: IFirebaesRepository{
    typealias T = IAvailabilityEvent
    
    private let collectionPath: String = "availabilityEvents"
    private let firebaseClient = FirebaseClient()
    private(set) var constants =  AvailabilityEventsRuningRepositoryConstants()
    
    func fetch(query: IQueryBuilder) async throws -> [any T] {
        let queryRef = query.build()
        let snapshot = try await queryRef.getDocuments()
        let documents = snapshot.documents
        let availabilityEvents = documents.compactMap { doc -> (any IAvailabilityEvent)? in
            let data = doc.data()
            let id = doc.documentID
            guard let notes = data["notes"] as? String else {
                return nil
            }
            guard let gMap = data["g"] as? [String: Any],
                  let geohash = gMap["geohash"] as? String,
                  let geopoint = gMap["geopoint"] as? GeoPoint else {
                return nil
            }
                  
            return AvailabilityEvent(
                id: id,
                geohash: geohash,
                geoPoint: geopoint,
                notes: notes,
                
            )
        }
        return availabilityEvents
    }
        
    
    func fetchById(_ id: String) async throws -> (any T)? {
        return nil
    }
    
    func create(_ item: any T) async throws -> String {
        return ""
    }
    
    func update(_ id: String, _ item: any T) async throws {
        
    }
    
    
    
    func delete(_ id: String) async throws {
        
    }
    
    func initQueryBuilderObject() -> IQueryBuilder {
        return QueryCollectionGroupBuilder(collectionGroupId: collectionPath, firebaseClient: firebaseClient)
    }
    
    
}
