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

class AvailbilityViewModel: ObservableObject{
    @Published var locationManager: LocationManager
    @Published var cameraPosition: MapCameraPosition = .automatic
    private var cancellables = Set<AnyCancellable>()
    @Published var anchorsClusters: [AnchorCluster] = []
    
    
    init(locationManager: LocationManager){
        self.locationManager = locationManager
        requestPermissionForLocation()
        Task{
            try! await fetchClusters()
        }
        
    }
    
    private func requestPermissionForLocation(){
        locationManager.requestPermission()
    }

    private func setupLocationObserver() {
       locationManager.$userLocation
           .compactMap { $0 }
           .first()
           .sink { [weak self] coordinate in
               self?.cameraPosition = .region(
                   MKCoordinateRegion(
                       center: coordinate,
                       span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                   )
               )
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
        let repo = AvailabilityAggregateRepository()
        let clusters = try await repo.fetch(query: createQuery(repo: repo))
        anchorsClusters = clusters.map{ AnchorCluster(cluster: $0) }
    }
    
    private func createQuery(repo: AvailabilityAggregateRepository) -> QueryBuilder{
        let cityPrefix = GeohashService.shared.getCityPrefix()
        var query = repo.initQueryBuilderObject()
        return query.appendFilter(Filter(field: repo.constants.geohashKey, operation: .isGreaterThanOrEqualTo, value: "u0n"))
    }
    
    func zoomToFitClusters() {
        guard !anchorsClusters.isEmpty else { return }
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
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
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
            
            let span = MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) * 1.3, // Add 30% padding
                longitudeDelta: (maxLon - minLon) * 1.3
            )
            
            return MKCoordinateRegion(center: center, span: span)
        }
}


