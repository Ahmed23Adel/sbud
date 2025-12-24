//
//  AvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import FirebaseFirestore

class AvailabilityEvent: IAvailabilityEvent{
    var id: String
    var geohash: String
    var geoPoint: GeoPoint
    var notes: String
    var userOwner: (any IOtherUser)?
    
    init(id: String, geohash: String, geoPoint: GeoPoint, notes: String) {
        self.id = id
        self.geohash = geohash
        self.geoPoint = geoPoint
        self.notes = notes
    }
    
    
    static func == (lhs: AvailabilityEvent, rhs: AvailabilityEvent) -> Bool {
        lhs.id == rhs.id
    }
    
    
}
