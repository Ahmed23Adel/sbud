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
class MapsHelper{
    private(set) var cityZoomLatitudeDelta: Double = 0.15
    private(set) var cityZoomLongitudeDelta: Double = 0.15
    
    func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return getInitialValueForSpan()
        }
        
        let (minLat, maxLat, minLon, maxLon) = calcMinMaxLatLon(coordinates:  coordinates)
        let center = calcCenterForLoc(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
        let (latDelta, lonDelta) = calcDelta(maxLat: maxLat, minLat: minLat, maxLon: maxLon, minLon: minLon)
        
        let span = MKCoordinateSpan(
            latitudeDelta: latDelta,
            longitudeDelta: lonDelta
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func calcMinMaxLatLon(coordinates:  [CLLocationCoordinate2D]) -> (Double, Double, Double, Double){
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude
        
        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }
        return (minLat, maxLat, minLon, maxLon)
    }
    
    func calcCenterForLoc(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> CLLocationCoordinate2D{
        CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
    }
    
    func calcDelta(maxLat: Double, minLat: Double, maxLon: Double, minLon: Double) -> (Double, Double){
        let latDelta = max((maxLat - minLat) * 1.3, cityZoomLatitudeDelta)
        let lonDelta = max((maxLon - minLon) * 1.3, cityZoomLongitudeDelta)
        return (latDelta, lonDelta)
    }
    
    func getInitialValueForSpan() -> MKCoordinateRegion{
        MKCoordinateRegion(
            center: LocationManager.shared.userLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(
                latitudeDelta: cityZoomLatitudeDelta,
                longitudeDelta: cityZoomLongitudeDelta
            )
        )
    }
    
    func calcuRegions(center: CLLocationCoordinate2D, latDelta: Double, lonDelta: Double) -> MKCoordinateRegion{
        let span = MKCoordinateSpan(
            latitudeDelta: latDelta,
            longitudeDelta: lonDelta
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    
    func determinePrecision(from region: MKCoordinateRegion) -> GeohashPrecision {
        let latitudeDelta = region.span.latitudeDelta
        
        switch latitudeDelta {
        case 0...0.01:  // Very zoomed in (~1km)
            return .individuals
        case 0.01...0.05:  // Zoomed in (~5km)
            return .neighbourhood
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
}
