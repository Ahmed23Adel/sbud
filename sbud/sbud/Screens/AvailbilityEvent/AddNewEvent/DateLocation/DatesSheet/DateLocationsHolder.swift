//
//  DateLocationsHolder.swift
//  sbud
//
//  Created by ahmed on 07/03/2026.
//

import Foundation
import FirebaseFirestore

struct DateLocationsHolder: Identifiable{
    var id = UUID()
    var startDate: Date
    var endDate: Date
    var locations: [GeoPoint]
}
