//
//  IFlattenedEvent.swift
//  sbud
//
//  Created by ahmed on 24/01/2026.
//

import Foundation
import Firebase

protocol IFlattenedEvent: Identifiable, Equatable{
    var id: String { get }
    var eventId: String { get }
    var dateLocationId: String { get }
    var activityType: ActivityTypes { get }
    var createdAt: Date { get }
    
    var eventImage: String { get }
    var isDateConfirmed: Bool { get }
    var isLocationConfirmed: Bool { get }
    var isPublic: Bool { get }
    var geohash: String { get }
    var geoPoint: GeoPoint { get }

}
