//
//  IAvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import FirebaseFirestore

protocol IAvailabilityEvent: Identifiable, Equatable {
    nonisolated var id: String { get set }
    var geoPoint: GeoPoint { get set }
    var eventImage: String { get }

}
