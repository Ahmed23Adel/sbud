//
//  Response.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import FirebaseFirestore
/// For some reasone, swift reads these two sturcts as @MainActor
/// But sendable means, "safe to cross concurrency boundaries" — but a main-actor type is pinned to one actor
///    so i haed to make these two structs non-isoloated(unsafe)
///    nonisolated:  "this type is NOT bound to any actor (not @MainActor, not anything)"
///    unsafe: "I'm promising you it's safe to cross concurrency boundaries; don't check me on this"
///    plz remember for swift; nonisolated in actor works with let
///    with var nonisolated(unsafe) You're telling the compiler: "let anyone access this from any context, and I promise I'll handle the thread safety myself"

nonisolated struct ActivityCluster: Decodable, Sendable {
    let geohash: String
    let count: Int
    let centerCoordinate: Coordinate

    func convertToAnchorCluster() -> AnchorCluster {
        AnchorCluster(cluster: AvailabiltiyAggregate(
            id: UUID().uuidString,
            count: count,
            location: GeoPoint(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude))
        )
    }
}

nonisolated struct AvailabitlityClusterResponse: Decodable, Sendable {
    let clusters: [ActivityCluster]
}
