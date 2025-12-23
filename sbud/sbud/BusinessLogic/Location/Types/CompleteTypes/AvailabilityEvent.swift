//
//  AvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

class AvailabilityEvent: IAvailabilityEvent{
    var id: String
    var geohash: String
    var geoPoint: String
    var notes: String
    var userOwner: any IOtherUser
    
    init(id: String, geohash: String, geoPoint: String, notes: String, userOwner: any IOtherUser) {
        self.id = id
        self.geohash = geohash
        self.geoPoint = geoPoint
        self.notes = notes
        self.userOwner = userOwner
    }
    
    
    static func == (lhs: AvailabilityEvent, rhs: AvailabilityEvent) -> Bool {
        lhs.id == rhs.id
    }
    
    
}
