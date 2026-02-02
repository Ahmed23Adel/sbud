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
        selectedActivityType: ActivityType
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
    
    private func createQueryForIndividual(
        region: MKCoordinateRegion,
        selectedStartDateTime: Date,
        selectedEndDateTime: Date,
        selectedActivityType: ActivityType
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
        selectedActivityType: ActivityType
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
                                        selectedActivityType: ActivityType) -> AvailabilityClusterModelRequest {
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
