//
//  Response.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import FirebaseFirestore

nonisolated(unsafe) struct ActivityCluster: Decodable, Sendable {
    let geohash: String
    let count: Int
    let centerCoordinate: Coordinate
    
    func convertToAnchorCluster() -> AnchorCluster{
        AnchorCluster(cluster: AvailabiltiyAggregate(
            id: UUID().uuidString,
            count: count,
            location: GeoPoint(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude))
        )
    }
}

nonisolated(unsafe) struct AvailabitlityClusterResponse: Decodable, Sendable {
    let clusters: [ActivityCluster]
}

