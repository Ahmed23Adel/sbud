//
//  AvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 22/12/2025.
//

import Foundation
import CoreLocation

struct AvailabilityEvent: Identifiable, Codable, Equatable{
    let id: String
    let firstName: String
    let lastName: String
    let bio: String?
    let profilePicture: String?
    let activities: [ActivityTypes]
    let experienceLevel: [ExperienceLevels]
    let primaryActivity: ActivityTypes
    let timeZone: String
    let totalWorkouts: Int
    let location: GeoPoint
    
    var coordinate: CLLocationCoordinate2D{
        CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }
}
