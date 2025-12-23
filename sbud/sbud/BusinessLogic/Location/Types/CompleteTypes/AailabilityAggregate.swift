//
//  AailabilityAggregate.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import FirebaseFirestore


struct AvailabiltiyAggregate: IAailabilityAggregate{
    var id: String
    var count: Int
    var geohash: String
    var location: GeoPoint
    var precision: Int
    
    init(id: String, count: Int, geohash: String, location: GeoPoint, precision: Int){
        self.id = id
        self.count = count
        self.geohash = geohash
        self.location = location
        self.precision = precision
    }
    
    static func == (lhs: AvailabiltiyAggregate, rhs: AvailabiltiyAggregate) -> Bool{
        lhs.id == rhs.id
    }
    
}
