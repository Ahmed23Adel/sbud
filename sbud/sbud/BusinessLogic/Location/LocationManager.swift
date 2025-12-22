//
//  LocationManager.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject{
    private let locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init(){
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission(){
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdating(){
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating(){
        locationManager.stopUpdatingLocation()
    }
    
}
extension LocationManager: CLLocationManagerDelegate{
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            startUpdating()
        }
    }
    // gets called whenever iOS gets new location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location  = locations.last else { return }
        userLocation = location.coordinate
    }
}
