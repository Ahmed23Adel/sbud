//
//  AailabilityAggregate.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import FirebaseFirestore

struct AvailabiltiyAggregate: IAailabilityAggregate {
    var id: String
    var count: Int
    var location: GeoPoint

    static func == (lhs: AvailabiltiyAggregate, rhs: AvailabiltiyAggregate) -> Bool {
        lhs.id == rhs.id
    }

}
