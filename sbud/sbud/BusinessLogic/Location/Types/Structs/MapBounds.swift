//
//  MapBounds.swift
//  sbud
//
//  Created by ahmed on 22/12/2025.
//

import Foundation
import CoreLocation

struct MapBounds{
    let northEast: CLLocationCoordinate2D
    let southWest: CLLocationCoordinate2D
    let center: CLLocationCoordinate2D
    let spanKM: Double
}
