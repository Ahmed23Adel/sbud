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
    private let collectionPath: String = "availabilityAggregates"
    private let firebaseClient = FirebaseClient()
    private(set) var constants =  AvailabilityAggregateRepositoryConstants()
    
    func fetch(query: QueryBuilder) async throws -> [any T] {
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
    
    func create(_ item: any T) async throws -> String {
        return ""
    }
    
    func update(_ id: String, _ item: any T) async throws {
        
    }
    
    func delete(_ id: String) async throws {
        
    }
    
    func initQueryBuilderObject() -> QueryBuilder{
        return QueryBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
         
    }
}
