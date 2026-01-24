//
//  FlattenedEvent.swift
//  sbud
//
//  Created by ahmed on 24/01/2026.
//

import Foundation
import Firebase


struct FlattenedEvent: IFlattenedEvent{
    var id: String
    var eventId: String
    var dateLocationId: String
    var activityType: ActivityTypes
    var createdAt: Date
    var eventImage: String
    var isDateConfirmed: Bool
    var isLocationConfirmed: Bool
    var isPublic: Bool
    var geohash: String
    var geoPoint: GeoPoint
    
    init(id: String, eventId: String, dateLocationId: String, activityType: ActivityTypes, createdAt: Date, eventImage: String, isDateConfirmed: Bool, isLocationConfirmed: Bool, isPublic: Bool, geohash: String, geoPoint: GeoPoint) {
        self.id = id
        self.eventId = eventId
        self.dateLocationId = dateLocationId
        self.activityType = activityType
        self.createdAt = createdAt
        self.eventImage = eventImage
        self.isDateConfirmed = isDateConfirmed
        self.isLocationConfirmed = isLocationConfirmed
        self.isPublic = isPublic
        self.geohash = geohash
        self.geoPoint = geoPoint
    }
    
    static func == (lhs: FlattenedEvent, rhs: FlattenedEvent) -> Bool{
        lhs.id == rhs.id
    }
    
    
}
