//
//  AvailabilityModelRequest.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import FirebaseFirestore

// `Sendable` means: **"this type is safe to use across any thread, with no actor restrictions."**
// But Swift now sees:
//- `FlattenedEventResponse`'s `Decodable` conformance = `@MainActor` (main thread only) (bcz it was called in main actor context probably)
//- `Sendable` = any thread
//Sendable    =  "any thread"


// Under the hood, Decodable conformance generates a real function:
// this generated function is a piece of code that lives somewhere. And in Swift 6, every piece of code must belong to a concurrency context — either an actor, or nonisolated.
// probabaly in @mainactor
nonisolated struct FlattenedEventResponse: Decodable, Sendable {
    let events: [Event]
    let count: Int

}

struct Event: Decodable, Sendable {
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
    let creatorName: String

    func covertToAnchor() -> AnchorAvailabilityEvent {
        AnchorAvailabilityEvent(eventId: self.eventId, event: AvailabilityEvent(
            id: id,
            eventId: eventId,
            geoPoint: GeoPoint(latitude: g.geopoint.latitude, longitude: g.geopoint.longitude),
            dateLocationId: dateLocationId,
            activityType: activityType,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            createdAt: createdAt,
            g: GeoLocation(geopoint: Coordinate(latitude: g.geopoint.latitude, longitude: g.geopoint.longitude), geohash: g.geohash),
            isDateConfirmed: isDateConfirmed,
            isLocationConfirmed: isLocationConfirmed,
            isPublic: isPublic,
            eventImage: eventImage,
            creatorName: creatorName
        )
        )
    }
}

struct GeoLocation: Decodable, Sendable {
    let geopoint: Coordinate
    let geohash: String
}
