//
//  Response.swift
//  sbud
//
//  Created by ahmed on 25/01/2026.
//

import Foundation
import FirebaseFirestore

struct EventCluster: Codable {
    let geohash: String
    let count: Int
    let centerCoordinate: ClusterCoordinate
}

struct ClusterCoordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    var geoPoint: GeoPoint {
        return GeoPoint(latitude: latitude, longitude: longitude)
    }
}

struct EventClusterMetadata: Codable {
    let processedEvents: Int
    let matchingEvents: Int
    let clusterDuplicatesSkipped: Int
    let outsideBounds: Int
    let clusterCount: Int
}

struct EventClusterResponse: Codable {
    let clusters: [EventCluster]
    let metadata: EventClusterMetadata
}
