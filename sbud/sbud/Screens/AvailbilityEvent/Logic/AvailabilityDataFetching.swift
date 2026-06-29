//
//  AvailabilityDataFetching.swift
//  sbud
//

import Foundation
import MapKit
import FirebaseFirestore

protocol AvailabilityDataFetching {
    func fetchIndividuals(
        in region: MKCoordinateRegion,
        selectedStartDateTime: Date,
        selectedEndDateTime: Date,
        selectedActivityType: ActivityType,
        extraFilters: [String: String]
    ) async throws -> [AnchorAvailabilityEvent]

    func fetchClusters(
        selectedStartTime: Date,
        selectedEndTime: Date,
        topLeft: GeoPoint,
        bottomRight: GeoPoint,
        selectedActivityType: ActivityType,
        extraFilters: [String: String]
    ) async throws -> [AnchorCluster]
}
