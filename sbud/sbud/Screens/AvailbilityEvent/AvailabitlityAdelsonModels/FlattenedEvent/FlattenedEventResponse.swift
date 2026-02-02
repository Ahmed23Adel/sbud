//
//  AvailabilityModelRequest.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import FirebaseFirestore

nonisolated(unsafe) struct FlattenedEventResponse: Decodable, Sendable {
    let events: [Event]
    let count: Int

}

nonisolated(unsafe) struct Event: Decodable, Sendable {
    let id: String
    let eventId: String
    let dateLocationId: String
    let activityType: String
    let startDateTime: Date
    let endDateTime: Date
    let createdAt: Date
    let g: GeoLocation
    let isDateConfirmed: Bool
    let isLocationConfirmed: Bool
    let isPublic: Bool
    let eventImage: String

    func covertToAnchor() -> AnchorAvailabilityEvent {
        AnchorAvailabilityEvent(event: AvailabilityEvent(
            id: id,
            geoPoint: GeoPoint(latitude: g.geopoint.latitude, longitude: g.geopoint.longitude),
            ownerProfilePicture: eventImage)
        )
    }
}

nonisolated(unsafe) struct GeoLocation: Decodable, Sendable {
    let geopoint: Coordinate
    let geohash: String
}
