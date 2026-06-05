//
//  LocationProviding.swift
//  sbud
//

import CoreLocation

protocol LocationProviding: AnyObject {
    var userLocation: CLLocationCoordinate2D? { get }
    func requestPermission()
}
