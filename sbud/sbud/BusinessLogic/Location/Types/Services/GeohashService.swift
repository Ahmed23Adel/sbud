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

    @Published var currentLocation: CLLocation?

    private var cancellables = Set<AnyCancellable>()

    private init() {
        if let currentCoordinate = LocationManager.shared.userLocation {
            let location = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
            currentLocation = location
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
            }
            .store(in: &cancellables)
    }
}
