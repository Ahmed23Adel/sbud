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

    // MARK: - Cache

    private static let cacheTTL: TimeInterval = 180 // 3 minutes

    private struct CacheEntry<T> {
        let results: T
        let cachedAt: Date

        var isExpired: Bool {
            Date().timeIntervalSince(cachedAt) > AvailabilityDataFetcher.cacheTTL
        }
    }

    private var clustersCache: [String: CacheEntry<[AnchorCluster]>] = [:]
    private var individualsCache: [String: CacheEntry<[AnchorAvailabilityEvent]>] = [:]

    private func clustersKey(
        topLeft: GeoPoint,
        bottomRight: GeoPoint,
        activityType: String,
        startTime: Date,
        endTime: Date,
        extraFilters: [String: String]
    ) -> String {
        let centerLat = (topLeft.latitude + bottomRight.latitude) / 2
        let centerLon = (topLeft.longitude + bottomRight.longitude) / 2
        // precision 4 → ~40 km × 20 km cells, appropriate for cluster-level zoom
        let geohash = Geohash.encode(latitude: centerLat, longitude: centerLon, length: 4)
        let filtersKey = extraFilters.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
        return "\(geohash)|\(activityType)|\(Int(startTime.timeIntervalSince1970))|\(Int(endTime.timeIntervalSince1970))|\(filtersKey)"
    }

    private func individualsKey(
        region: MKCoordinateRegion,
        activityType: String,
        startTime: Date,
        endTime: Date,
        extraFilters: [String: String]
    ) -> String {
        // precision 6 → ~1.2 km × 0.6 km cells, appropriate for individual-event zoom
        let geohash = Geohash.encode(latitude: region.center.latitude, longitude: region.center.longitude, length: 6)
        let filtersKey = extraFilters.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: ",")
        return "\(geohash)|\(activityType)|\(Int(startTime.timeIntervalSince1970))|\(Int(endTime.timeIntervalSince1970))|\(filtersKey)"
    }

    // MARK: - Individuals

    func fetchIndividuals(
        in region: MKCoordinateRegion,
        selectedStartDateTime: Date,
        selectedEndDateTime: Date,
        selectedActivityType: ActivityType,
        extraFilters: [String: String]
    ) async throws -> [AnchorAvailabilityEvent] {
        let key = individualsKey(
            region: region,
            activityType: selectedActivityType.rawValue,
            startTime: selectedStartDateTime,
            endTime: selectedEndDateTime,
            extraFilters: extraFilters
        )

        if let entry = individualsCache[key], !entry.isExpired {
            logger.debug("Cache hit (individuals): \(key)")
            return entry.results
        }

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

        individualsCache[key] = CacheEntry(results: anchors, cachedAt: Date())
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
        let key = clustersKey(
            topLeft: topLeft,
            bottomRight: bottomRight,
            activityType: selectedActivityType.rawValue,
            startTime: selectedStartTime,
            endTime: selectedEndTime,
            extraFilters: extraFilters
        )

        if let entry = clustersCache[key], !entry.isExpired {
            logger.debug("Cache hit (clusters): \(key)")
            return entry.results
        }

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

        clustersCache[key] = CacheEntry(results: anchors, cachedAt: Date())
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
