//
//  IAvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import FirebaseFirestore

protocol IAvailabilityEvent: Identifiable, Identifiable, Equatable{
    var id: String { get set }
    var geohash: String { get set }
    var geoPoint: GeoPoint { get set }
    var ownerProfilePicture: String { get }
    
    
}
