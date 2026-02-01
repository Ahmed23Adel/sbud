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
import FirebaseCore

class AvailabilityDataFetcher {
    
    private let individualsPrecision = 6
    private let individualsLimit = 200
    private let clustersLimit = 100
    
    // MARK: - Individuals
    
    func fetchIndividuals(
        in region: MKCoordinateRegion,
        selectedStartDateTime: Date,
        selectedEndDateTime: Date,
        selectedActivityType: ActivityTypes
    ) async throws -> [AnchorAvailabilityEvent] {
        let requestParams = createQueryForIndividual(
            region: region,
            selectedStartDateTime: selectedStartDateTime,
            selectedEndDateTime: selectedEndDateTime,
            selectedActivityType: selectedActivityType)
        
        let requester = FlattenedEventsRequester()
        let results = try await requester.fetchIndividuals(requestParams: requestParams)
        let anchors = results.events.map{ $0.covertToAnchor() }
        return anchors
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
    
    private func createQueryForIndividual(
        region: MKCoordinateRegion,
        selectedStartDateTime: Date,
        selectedEndDateTime: Date,
        selectedActivityType: ActivityTypes
    ) -> FlattenedEventsRequest {
        
        let request = FlattenedEventsRequest(
            topLeft: region.topLeft,
            bottomRight: region.bottomRight,
            selectedActivityType: selectedActivityType.rawValue,
            selectedStartTime: selectedStartDateTime,
            selectedEndTime: selectedEndDateTime
        
       )
        return request
    }
    
    // MARK: - Clusters
    func   fetchClusters(
        selectedStartTime: Date,
        selectedEndTime: Date,
        topLeft: GeoPoint,
        bottomRight: GeoPoint,
        selectedActivityType: ActivityTypes
    ) async throws -> [AnchorCluster] {
        let requestParams = createRequestParamsForClusters(
            selectedStartTime: selectedStartTime,
            selectedEndTime: selectedEndTime,
            topLeft: topLeft,
            bottomRight: bottomRight,
            selectedActivityType: selectedActivityType
        )
        
        let requester = AvailbilityClusterRequester()
        let results = try await requester.fetchClusters(requestParams: requestParams)
        let anchors = results.clusters.map{ $0.convertToAnchorCluster() }
        return anchors
    }
    
    private func createRequestParamsForClusters(selectedStartTime: Date,
                                        selectedEndTime: Date,
                                        topLeft: GeoPoint,
                                        bottomRight: GeoPoint,
                                        selectedActivityType: ActivityTypes) -> AvailabilityClusterModelRequest {
        let request = AvailabilityClusterModelRequest(
            topLeft: topLeft,
            bottomRight: bottomRight,
            selectedActivityType: selectedActivityType.rawValue,
            selectedStartTime: selectedStartTime,
            selectedEndTime: selectedEndTime,
            precision: GeohashPrecision.district.rawValue
            
        )

        return request
    }
}
