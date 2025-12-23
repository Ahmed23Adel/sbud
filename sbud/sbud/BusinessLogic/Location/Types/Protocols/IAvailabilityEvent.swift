//
//  IAvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

protocol IAvailabilityEvent: Identifiable, Identifiable, Equatable{
    var id: String { get set }
    var geohash: String { get set }
    var geoPoint: String { get set }
    var notes: String { get set }
    var userOwner: any IOtherUser { get set }
    
}
