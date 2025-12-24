//
//  GeohashService.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import CoreLocation
import Geohash
import Combine

class GeohashService: ObservableObject {
    static let shared = GeohashService()
    
    @Published var currentGeohash: String?
    @Published var cityPrefix: String?
    @Published var currentLocation: CLLocation?
    @Published var geohashBounds: (min: String, max: String)?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        if let currentCoordinate = LocationManager.shared.userLocation {
            let location = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
            currentLocation = location
            updateGeohash(for: currentCoordinate)
        }
        setupLocationObserver()
    }
    
    private func setupLocationObserver() {
        LocationManager.shared.$userLocation
            .compactMap { $0 }
            .removeDuplicates(by: { old, new in
                old.latitude == new.latitude && old.longitude == new.longitude
            })
            .sink { [weak self] coordinate in
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self?.currentLocation = location
                self?.updateGeohash(for: coordinate)
            }
            .store(in: &cancellables)
    }
    
    private func updateGeohash(for coordinate: CLLocationCoordinate2D) {
        // Full geohash with precision 4
        currentGeohash = encode(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            precision: 4
        )
        
        // City-level prefix (3 characters)
        cityPrefix = getCityPrefix()
        
        // Calculate bounds for querying
        geohashBounds = calculateGeohashBounds(precision: 3)
    }
    
    // MARK: - Public Methods
    
    /// Get city-level geohash prefix using current location
    func getCityPrefix() -> String? {
        guard let location = currentLocation else { return nil }
        let fullGeohash = encode(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            precision: 4
        )
        return String(fullGeohash.prefix(4))
    }
    
    /// Calculate geohash bounds for querying
    func calculateGeohashBounds(precision: Int = 4) -> (min: String, max: String)? {
        guard let location = currentLocation else { return nil }
        
        let geohash = encode(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            precision: precision
        )
        let prefix = String(geohash.prefix(precision))
        return (min: prefix, max: prefix + "~")
    }
    
    /// Encode current location to geohash
    func encode(precision: Int = 4) -> String? {
        guard let location = currentLocation else { return nil }
        return encode(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            precision: precision
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func encode(latitude: Double, longitude: Double, precision: Int) -> String {
        return Geohash.encode(latitude: latitude, longitude: longitude, length: precision)
    }
}
