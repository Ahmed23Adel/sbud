//
//  Response.swift
//  sbud
//
//  Created by ahmed on 26/01/2026.
//

import Foundation
import FirebaseFirestore

struct FFlattenedEventsResponse: Codable {
    let events: [FFlattenedEvent]
    let metadata: FlattenedEventsMetadata
    
    init(from dictionary: [String: Any]) throws {
        guard let eventsArray = dictionary["events"] as? [[String: Any]],
              let metadataDict = dictionary["metadata"] as? [String: Any] else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Missing required fields in response"
                )
            )
        }
        
        self.events = eventsArray.compactMap { FFlattenedEvent(from: $0) }
        self.metadata = FlattenedEventsMetadata(from: metadataDict)
    }
}

struct FlattenedEventsMetadata: Codable {
    let processedEvents: Int
    let duplicates: Int
    let outsideBounds: Int
    let outsideTimeBounds: Int
    let returnedEvents: Int
    
    init(from dictionary: [String: Any]) {
        self.processedEvents = dictionary["processedEvents"] as? Int ?? 0
        self.duplicates = dictionary["duplicates"] as? Int ?? 0
        self.outsideBounds = dictionary["outsideBounds"] as? Int ?? 0
        self.outsideTimeBounds = dictionary["outsideTimeBounds"] as? Int ?? 0
        self.returnedEvents = dictionary["returnedEvents"] as? Int ?? 0
    }
}
struct FFlattenedEvent: Codable {
    let id: String
    let eventId: String
    let activityType: String
    let startDateTime: Date
    let endDateTime: Date
    let location: EventLocation
    let isPublic: Bool
    let isDateConfirmed: Bool
    let isLocationConfirmed: Bool
    let eventImage: String?
    let dateLocationId: String
    let createdAt: Date
    
    init?(from dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let eventId = dictionary["eventId"] as? String,
              let activityType = dictionary["activityType"] as? String,
              let startTimestampDict = dictionary["startDateTime"] as? [String: Any],
              let endTimestampDict = dictionary["endDateTime"] as? [String: Any],
              let locationDict = dictionary["location"] as? [String: Any],
              let isPublic = dictionary["isPublic"] as? Bool,
              let isDateConfirmed = dictionary["isDateConfirmed"] as? Bool,
              let isLocationConfirmed = dictionary["isLocationConfirmed"] as? Bool,
              let dateLocationId = dictionary["dateLocationId"] as? String,
              let createdTimestampDict = dictionary["createdAt"] as? [String: Any] else {
            return nil
        }
        
        // Convert timestamp dictionaries to Dates
        guard let startDate = Self.dateFromTimestampDict(startTimestampDict),
              let endDate = Self.dateFromTimestampDict(endTimestampDict),
              let createdDate = Self.dateFromTimestampDict(createdTimestampDict) else {
            return nil
        }
        
        self.id = id
        self.eventId = eventId
        self.activityType = activityType
        self.startDateTime = startDate
        self.endDateTime = endDate
        self.isPublic = isPublic
        self.isDateConfirmed = isDateConfirmed
        self.isLocationConfirmed = isLocationConfirmed
        self.eventImage = dictionary["eventImage"] as? String
        self.dateLocationId = dateLocationId
        self.createdAt = createdDate
        
        guard let location = EventLocation(from: locationDict) else {
            return nil
        }
        self.location = location
    }
    
    // Helper to convert timestamp dictionary to Date
    private static func dateFromTimestampDict(_ dict: [String: Any]) -> Date? {
        guard let seconds = dict["_seconds"] as? TimeInterval else {
            return nil
        }
        let nanoseconds = dict["_nanoseconds"] as? TimeInterval ?? 0
        return Date(timeIntervalSince1970: seconds + (nanoseconds / 1_000_000_000))
    }
}

struct EventLocation: Codable {
    let geohash: String
    let geopoint: GeoPoint
    
    init?(from dictionary: [String: Any]) {
        guard let geohash = dictionary["geohash"] as? String,
              let geopointDict = dictionary["geopoint"] as? [String: Any],
              let latitude = geopointDict["_latitude"] as? Double,
              let longitude = geopointDict["_longitude"] as? Double else {
            return nil
        }
        
        self.geohash = geohash
        self.geopoint = GeoPoint(latitude: latitude, longitude: longitude)
    }
}
