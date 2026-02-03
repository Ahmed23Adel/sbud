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
    var extensionAmount: Double {
        0.05
    }
    var topLeft: GeoPoint {
        GeoPoint(latitude: center.latitude + (span.latitudeDelta / 2),
                 longitude: center.longitude - (span.longitudeDelta / 2))
    }

    var bottomRight: GeoPoint {
        GeoPoint(latitude: center.latitude - (span.latitudeDelta / 2),
                 longitude: center.longitude + (span.longitudeDelta / 2))
    }
    
    var topLeftExtended: GeoPoint {
        GeoPoint(
            latitude: topLeft.latitude + extensionAmount,
            longitude: topLeft.latitude - extensionAmount
        )
    }
    
    var bottomRightExtended: GeoPoint {
        GeoPoint(
            latitude: bottomRight.latitude - extensionAmount,
            longitude: bottomRight.latitude + extensionAmount
        )
    }
    
}
