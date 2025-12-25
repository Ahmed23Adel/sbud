//
//  AvailabilityAggregateRepository.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import FirebaseFirestore

class AvailabilityAggregateRepository: IFirebaesRepository{
    typealias T = IAailabilityAggregate
    
    let collectionPath: String = "availabilityAggregates"
    let firebaseClient = FirebaseClient()
    var constants =  AvailabilityAggregateRepositoryConstants()
    
    func fetch(query: IQueryBuilder) async throws -> [any T] {
        let queryRef = query.build()
        let snapshot = try await queryRef.getDocuments()
        let documents = snapshot.documents
        let aggregates = documents.compactMap { doc -> (any IAailabilityAggregate)? in
            let data = doc.data()
            guard let count = data["count"] as? Int,
                  let geohash = data["geohash"] as? String,
                  let location = data["location"] as? GeoPoint,
                  let precision = data["precision"] as? Int else {
                return nil
            }
            return AvailabiltiyAggregate(
                id: doc.documentID,
                count: count,
                geohash: geohash,
                location: location,
                precision: Int(precision)
            )
        }
        return aggregates
    }
    
    func fetchById(_ id: String) async throws -> (any T)? {
        return nil
    }
    
    func fetchByIds(_ id: [String]) async throws -> [any T]? {
        return []
    }
    func create(_ item: any T) async throws -> String {
        return ""
    }
    
    func update(_ id: String, _ item: any T) async throws {
        
    }
    
    func delete(_ id: String) async throws {
        
    }
    
    func initQueryBuilderObject() -> IQueryBuilder{
        return QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
         
    }
}
