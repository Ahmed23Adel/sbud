//
//  MKCoordinateRegion.swift
//  sbud
//
//  Created by ahmed on 25/01/2026.
//

import Foundation
import MapKit
import FirebaseFirestore

extension MKCoordinateRegion {
    var topLeft: GeoPoint {
        GeoPoint(latitude: center.latitude + (span.latitudeDelta / 2),
                 longitude: center.longitude - (span.longitudeDelta / 2))
    }

    var bottomRight: GeoPoint {
        GeoPoint(latitude: center.latitude - (span.latitudeDelta / 2),
                 longitude: center.longitude + (span.longitudeDelta / 2))
    }
}
