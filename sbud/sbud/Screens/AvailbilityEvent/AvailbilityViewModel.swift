//
//  AvailbilityViewModel.swift
//  sbud
//
//  Created by ahmed on 22/12/2025.
//

import Foundation
import Combine
import _MapKit_SwiftUI
import FirebaseFirestore


class AvailbilityViewModel: ObservableObject {
    @Published var locationManager: LocationManager
    @Published var cameraPosition: MapCameraPosition = .automatic
    private var cancellables = Set<AnyCancellable>()
    @Published var anchorsClusters: [AnchorCluster] = []
    
    private let cityZoomLatitudeDelta: Double = 0.15
    private let cityZoomLongitudeDelta: Double = 0.15
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        requestPermissionForLocation()
        setupLocationObserver()
        setupGeohashListener()
        
        Task {
            try! await fetchClusters()
        }
    }
    
    private func requestPermissionForLocation() {
        locationManager.requestPermission()
    }
    
    private func setupLocationObserver() {
        locationManager.$userLocation
            .compactMap { $0 }
            .first()
            .sink { [weak self] coordinate in
                guard let self = self else { return }
                self.zoomToCity(center: coordinate)
            }
            .store(in: &cancellables)
    }
    
    private func setupGeohashListener() {
        GeohashService.shared.$cityPrefix
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    try await self?.fetchClusters()
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchClusters() async throws {
        let bounds = GeohashService.shared.calculateGeohashBounds()
        let repo = AvailabilityAggregateRepository()
        let query = createQuery(bounds: bounds!, repo: repo)
        let clusters = try await repo.fetch(query: query)
        
        await MainActor.run {
            self.anchorsClusters = clusters.map { AnchorCluster(cluster: $0) }
        }
    }
    
    private func createQuery(bounds: (min: String, max: String), repo: AvailabilityAggregateRepository) -> QueryBuilder {
        var query = repo.initQueryBuilderObject()
        query = query.appendFilter(
            Filter(field: repo.constants.geohashKey, operation: .isGreaterThanOrEqualTo, value: bounds.min)
        )
        query = query.appendFilter(
            Filter(field: repo.constants.geohashKey, operation: .isLessThan, value: bounds.max)
        )
        query = query.setLimit(100)
        return query
    }
    
    // MARK: - Zoom Functions
    func zoomToCity(center: CLLocationCoordinate2D? = nil) {
        let coordinate = center ?? locationManager.userLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: cityZoomLatitudeDelta,
                    longitudeDelta: cityZoomLongitudeDelta
                )
            )
        )
    }
    
    func zoomToFitClusters() {
        guard !anchorsClusters.isEmpty else {
            zoomToCity()
            return
        }
        let coordinates = anchorsClusters.map {
            CLLocationCoordinate2D(
                latitude: $0.cluster.location.latitude,
                longitude: $0.cluster.location.longitude
            )
        }
        
        let region = calculateRegion(for: coordinates)
        cameraPosition = .region(region)
    }
    
    private func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: LocationManager.shared.userLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(
                    latitudeDelta: cityZoomLatitudeDelta,
                    longitudeDelta: cityZoomLongitudeDelta
                )
            )
        }
        
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
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        // Ensure minimum zoom level (don't zoom in too much)
        let latDelta = max((maxLat - minLat) * 1.3, cityZoomLatitudeDelta)
        let lonDelta = max((maxLon - minLon) * 1.3, cityZoomLongitudeDelta)
        
        let span = MKCoordinateSpan(
            latitudeDelta: latDelta,
            longitudeDelta: lonDelta
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}
