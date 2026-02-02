//
//  AvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import FirebaseFirestore

class AvailabilityEvent: IAvailabilityEvent {
    var id: String
    var geoPoint: GeoPoint
    var ownerProfilePicture: String

    init(id: String, geoPoint: GeoPoint, ownerProfilePicture: String) {
        self.id = id
        self.geoPoint = geoPoint
        self.ownerProfilePicture = ownerProfilePicture
    }

    static func == (lhs: AvailabilityEvent, rhs: AvailabilityEvent) -> Bool {
        lhs.id == rhs.id
    }

}
