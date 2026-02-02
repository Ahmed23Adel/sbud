//
//  CamerHelper.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import _MapKit_SwiftUI
import FirebaseFirestore

/*
 1 char continent
 2  large country/region
 3 large city
 4 city or district
 5 Neighborhood
 */
class MapsHelper {
    private(set) var cityZoomLatitudeDelta: Double = 0.09
    private(set) var cityZoomLongitudeDelta: Double = 0.09

    func calcCenterForLoc(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
    }

    func calcDelta(maxLat: Double, minLat: Double, maxLon: Double, minLon: Double) -> (Double, Double) {
        let latDelta = max((maxLat - minLat) * 1.3, cityZoomLatitudeDelta)
        let lonDelta = max((maxLon - minLon) * 1.3, cityZoomLongitudeDelta)
        return (latDelta, lonDelta)
    }

    func getInitialValueForSpan() -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: LocationManager.shared.userLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(
                latitudeDelta: cityZoomLatitudeDelta,
                longitudeDelta: cityZoomLongitudeDelta
            )
        )
    }

    func determinePrecision(from region: MKCoordinateRegion) -> GeohashPrecision {
        let latitudeDelta = region.span.latitudeDelta

        switch latitudeDelta {
        case 0...0.01:  // Very zoomed in (~1km)
            return .individuals
        case 0.01...0.05:  // Zoomed in (~5km) // start showing individuals at bigger space
            return .individuals
        case 0.05...0.2:  // City level (~20km)
            return .city
        case 0.2...1.0:  // Large city (~100km)
            return .largeCity
        case 1.0...5.0:  // Country level
            return .country
        default:  // Very zoomed out
            return .continent
        }
    }

    func isNewRegionContained(new: MKCoordinateRegion, old: MKCoordinateRegion) -> Bool {
        if new.topLeft.latitude <= old.topLeft.latitude &&
            new.topLeft.longitude >= old.topLeft.longitude &&
            new.bottomRight.latitude >= old.bottomRight.latitude &&
            new.bottomRight.longitude <= old.bottomRight.longitude {
            return true
        }
        return false
    }
}
