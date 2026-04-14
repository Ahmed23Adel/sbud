//
//  IAvailabilityAggregate.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import FirebaseFirestore

protocol IAailabilityAggregate: Identifiable, Equatable {
    nonisolated var id: String { get }
    nonisolated var count: Int { get }
    nonisolated var location: GeoPoint { get }

}
