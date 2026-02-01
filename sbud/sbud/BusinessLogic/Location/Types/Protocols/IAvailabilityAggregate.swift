//
//  IAvailabilityAggregate.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import FirebaseFirestore


protocol IAailabilityAggregate: Identifiable, Equatable{
    var id: String { get }
    var count: Int { get }
    var location: GeoPoint { get }

}
