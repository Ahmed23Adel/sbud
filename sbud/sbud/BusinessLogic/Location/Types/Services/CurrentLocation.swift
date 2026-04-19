//
//  CurrentLocation.swift
//  sbud
//
//  Created by Erdal on 20.04.2026.
//

import Foundation
import Combine
import CoreLocation
import FirebaseAuth

final class CurrentLocationService: ObservableObject {

    static let shared = CurrentLocationService()
    
    private let minimumDistanceThreshold: CLLocationDistance = 100
    private let minimumUpdateInterval: TimeInterval = 60

    private let userRepository = UserRepository()
    private var cancellables = Set<AnyCancellable>()
    private var lastUploadedLocation: CLLocation?
    private var lastUploadTime: Date?

    @Published var lastError: Error?

    private init() {
        startObservingLocation()
    }

    private func startObservingLocation() {
        LocationManager.shared.$userLocation
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                self?.handleNewCoordinate(coordinate)
            }
            .store(in: &cancellables)
    }

    private func handleNewCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        if let last = lastUploadedLocation,
           newLocation.distance(from: last) < minimumDistanceThreshold { return }

        if let lastTime = lastUploadTime,
           Date().timeIntervalSince(lastTime) < minimumUpdateInterval { return }

        uploadToFirebase(coordinate: coordinate, location: newLocation)
    }

    private func uploadToFirebase(coordinate: CLLocationCoordinate2D, location: CLLocation) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let fields: [String: Any] = [
            "currentLocation": [
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude
            ]
        ]

        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.userRepository.updateUserProfileFields(uid: uid, fields: fields)
                self.lastUploadedLocation = location
                self.lastUploadTime = Date()
                await MainActor.run { self.lastError = nil }
            } catch {
                await MainActor.run { self.lastError = error }
            }
        }
    }

    func forceUpdate() {
        guard let coordinate = LocationManager.shared.userLocation else { return }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        uploadToFirebase(coordinate: coordinate, location: location)
    }
}
