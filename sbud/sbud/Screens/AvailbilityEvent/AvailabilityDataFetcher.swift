//
//  DataFetcher.swift
//  sbud
//
//  Created by ahmed on 25/12/2025.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore

class AvailabilityDataFetcher{
    
  
    func fetchIndividuals() async throws -> [AnchorAvailabilityEvent]{
        print("👥 fetchIndstarted")
        let queryPrecision = GeohashPrecision.city.rawValue
        let repo = AvailabilityEventsRepository()
        let bounds = GeohashService.shared.calculateGeohashBounds(precision: queryPrecision)
        let query = createQueryForIndividual(repo: repo, bounds: bounds ?? ("~", "~"))
        print("queryInd: ", query)
        let events = try await repo.fetch(query: query)
        print("Fetched \(events.count) individual events")
        let anchorAvailabilityEvents = events.map { AnchorAvailabilityEvent(event: $0) }
        print("📌 First few IDs: \(anchorAvailabilityEvents.prefix(3).map { $0.id })")
        return anchorAvailabilityEvents
        
    }
    
    func createQueryForIndividual(repo: AvailabilityEventsRepository, bounds: (min: String, max: String)) -> IQueryBuilder{
        var query = repo.initQueryBuilderObject()
        query = query.appendFilter(
            Filter(field: "g.geohash", operation: .isGreaterThanOrEqualTo, value: bounds.min)
        )
        query = query.appendFilter(
            Filter(field: "g.geohash", operation: .isLessThan, value: bounds.max)
        )
        query = query.setLimit(200)
        return query
    }
    
    func fetchClusters(precision: GeohashPrecision) async throws -> [AnchorCluster]{
        let queryPrecision = max(1, precision.rawValue - 1)
        let bounds = GeohashService.shared.calculateGeohashBounds(precision: queryPrecision)
        
        let repo = AvailabilityAggregateRepository()
        let query = createQueryForClusters(bounds: bounds!, repo: repo)
        var clusters = try await repo.fetch(query: query)
        
        clusters = clusters.filter{ $0.precision == precision.rawValue }
        let anchorsClusters = clusters.map { AnchorCluster(cluster: $0) }
        return anchorsClusters
    }
    
    func createQueryForClusters(bounds: (min: String, max: String), repo: AvailabilityAggregateRepository) -> IQueryBuilder {
        var query = repo.initQueryBuilderObject()
        query = query.appendFilter(
            Filter(field: repo.constants.geohashKey, operation: .isGreaterThanOrEqualTo, value: bounds.min)
        )
        query = query.appendFilter(
            Filter(field: repo.constants.geohashKey, operation: .isLessThan, value: bounds.max)
        )
        query = query.setLimit(100)
        return query
    }
}
