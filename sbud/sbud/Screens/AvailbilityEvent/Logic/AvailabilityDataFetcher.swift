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
import OSLog

class AvailabilityDataFetcher: AvailabilityDataFetching {

    private let individualsPrecision = 6
    private let individualsLimit = 200
    private let clustersLimit = 100
    private let logger = Logger(subsystem: "sBud", category: "AvailabilityDataFetcher")
    // MARK: - Individuals
    func fetchIndividuals(
        in region: MKCoordinateRegion,
        selectedStartDateTime: Date,
        selectedEndDateTime: Date,
        selectedActivityType: ActivityType,
        extraFilters: [String: String]
    ) async throws -> [AnchorAvailabilityEvent] {
        let requestParams = createQueryForIndividual(
            region: region,
            selectedStartDateTime: selectedStartDateTime,
            selectedEndDateTime: selectedEndDateTime,
            selectedActivityType: selectedActivityType,
            extraFilters: extraFilters
        )
        logger.info("Individual request: \(requestParams)")
        let requester = FlattenedEventsRequester()
        let results = try await requester.fetchIndividuals(requestParams: requestParams)
        let anchors = results.events.map { $0.covertToAnchor() }
//        logger.info("Individual sample results: \(anchors[0])")
        return anchors
    }

    private func createQueryForIndividual(
        region: MKCoordinateRegion,
        selectedStartDateTime: Date,
        selectedEndDateTime: Date,
        selectedActivityType: ActivityType,
        extraFilters: [String: String]
    ) -> FlattenedEventsRequest {

        let request = FlattenedEventsRequest(
            topLeft: region.topLeft,
            bottomRight: region.bottomRight,
            selectedActivityType: selectedActivityType.rawValue,
            selectedStartTime: selectedStartDateTime,
            selectedEndTime: selectedEndDateTime,
            extraFilters: extraFilters
       )
        logger.info("requestParams for individuals: \(request)")
        return request
    }

    // MARK: - Clusters
    func fetchClusters(
        selectedStartTime: Date,
        selectedEndTime: Date,
        topLeft: GeoPoint,
        bottomRight: GeoPoint,
        selectedActivityType: ActivityType,
        extraFilters: [String: String]
    ) async throws -> [AnchorCluster] {
        let requestParams = createRequestParamsForClusters(
            selectedStartTime: selectedStartTime,
            selectedEndTime: selectedEndTime,
            topLeft: topLeft,
            bottomRight: bottomRight,
            selectedActivityType: selectedActivityType,
            extraFilters: extraFilters
        )
        logger.info("requestParams for clusters: \(requestParams)")
        let requester = AvailbilityClusterRequester()
        let results = try await requester.fetchClusters(requestParams: requestParams)
        let anchors = results.clusters.map { $0.convertToAnchorCluster() }
        return anchors
    }

    private func createRequestParamsForClusters(selectedStartTime: Date,
                                                selectedEndTime: Date,
                                                topLeft: GeoPoint,
                                                bottomRight: GeoPoint,
                                                selectedActivityType: ActivityType,
                                                extraFilters: [String: String] ) -> AvailabilityClusterModelRequest {
        let request = AvailabilityClusterModelRequest(
            topLeft: topLeft,
            bottomRight: bottomRight,
            selectedActivityType: selectedActivityType.rawValue,
            selectedStartTime: selectedStartTime,
            selectedEndTime: selectedEndTime,
            precision: GeohashPrecision.district.rawValue,
            extraFilters: extraFilters
        )

        return request
    }
}
