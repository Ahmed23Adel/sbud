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
import _MapKit_SwiftUI
import Geohash

class AvailabilityDataFetcher {
    
    private let individualsPrecision = 6
    private let individualsLimit = 200
    private let clustersLimit = 100
    
    // MARK: - Individuals
    
    func fetchIndividuals(in region: MKCoordinateRegion?) async throws -> [AnchorAvailabilityEvent] {
        let bounds = region != nil
            ? calculateBoundsFromRegion(region!)
            : calculateBoundsFromUserLocation()
        
        let repo = AvailabilityEventsRepository()
        let query = createQueryForIndividual(repo: repo, bounds: bounds)
        let events = try await repo.fetch(query: query)
        return events.map { AnchorAvailabilityEvent(event: $0) }
    }
    
    private func calculateBoundsFromRegion(_ region: MKCoordinateRegion) -> (min: String, max: String) {
        let corners = getRegionCorners(region)
        let geohashes = corners.map { coordinate in
            Geohash.encode(latitude: coordinate.latitude, longitude: coordinate.longitude, length: individualsPrecision)
        }
        
        let commonPrefix = findCommonPrefix(geohashes)
        return commonPrefix.isEmpty
            ? (min: geohashes.min()!, max: geohashes.max()! + "~")
            : (min: commonPrefix, max: commonPrefix + "~")
    }
    
    private func calculateBoundsFromUserLocation() -> (min: String, max: String) {
        guard let location = GeohashService.shared.currentLocation else {
            return ("", "~")
        }
        
        let geohash = Geohash.encode(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            length: GeohashPrecision.city.rawValue
        )
        let prefix = String(geohash.prefix(GeohashPrecision.city.rawValue))
        return (min: prefix, max: prefix + "~")
    }
    
    private func getRegionCorners(_ region: MKCoordinateRegion) -> [CLLocationCoordinate2D] {
        let center = region.center
        let halfLat = region.span.latitudeDelta / 2
        let halfLon = region.span.longitudeDelta / 2
        
        return [
            CLLocationCoordinate2D(latitude: center.latitude - halfLat, longitude: center.longitude - halfLon),
            CLLocationCoordinate2D(latitude: center.latitude - halfLat, longitude: center.longitude + halfLon),
            CLLocationCoordinate2D(latitude: center.latitude + halfLat, longitude: center.longitude - halfLon),
            CLLocationCoordinate2D(latitude: center.latitude + halfLat, longitude: center.longitude + halfLon)
        ]
    }
    
    private func findCommonPrefix(_ strings: [String]) -> String {
        guard let first = strings.first, strings.count > 1 else { return strings.first ?? "" }
        
        var prefix = ""
        for (index, char) in first.enumerated() {
            guard strings.allSatisfy({ $0.count > index && $0[String.Index(utf16Offset: index, in: $0)] == char }) else {
                break
            }
            prefix.append(char)
        }
        return prefix
    }
    
    private func createQueryForIndividual(repo: AvailabilityEventsRepository, bounds: (min: String, max: String)) -> IQueryBuilder {
        var query = repo.initQueryBuilderObject()
        query = query.appendFilter(
            Filter(field: "g.geohash", operation: .isGreaterThanOrEqualTo, value: bounds.min)
        )
        query = query.appendFilter(
            Filter(field: "g.geohash", operation: .isLessThan, value: bounds.max)
        )
        query = query.setLimit(individualsLimit)
        return query
    }
    
    // MARK: - Clusters
    
    func fetchClusters(precision: GeohashPrecision) async throws -> [AnchorCluster] {
        let queryPrecision = max(1, precision.rawValue - 1)
        let bounds = calculateBoundsForClusters(precision: queryPrecision)
        
        let repo = AvailabilityAggregateRepository()
        let query = createQueryForClusters(bounds: bounds, repo: repo)
        let clusters = try await repo.fetch(query: query)
        
        return clusters
            .filter { $0.precision == precision.rawValue }
            .map { AnchorCluster(cluster: $0) }
    }
    
    private func calculateBoundsForClusters(precision: Int) -> (min: String, max: String) {
        guard let location = GeohashService.shared.currentLocation else {
            return ("", "~")
        }
        
        let geohash = Geohash.encode(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            length: precision
        )
        let prefix = String(geohash.prefix(precision))
        return (min: prefix, max: prefix + "~")
    }
    
    private func createQueryForClusters(bounds: (min: String, max: String), repo: AvailabilityAggregateRepository) -> IQueryBuilder {
        var query = repo.initQueryBuilderObject()
        query = query.appendFilter(
            Filter(field: repo.constants.geohashKey, operation: .isGreaterThanOrEqualTo, value: bounds.min)
        )
        query = query.appendFilter(
            Filter(field: repo.constants.geohashKey, operation: .isLessThan, value: bounds.max)
        )
        query = query.setLimit(clustersLimit)
        return query
    }
}
