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
    private let mapsHelper = MapsHelper()
    
    @Published var shouldShowIndividuals: Bool = false
    @Published var currentPrecision: GeohasPrecision = .neighbourhood
    
    @Published var alertMsg = ""
    @Published var showErrorAlert = false
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        requestPermissionForLocation()
        setupGeohashListener()
        fetchNewData()
    }
    
    private func requestPermissionForLocation() {
        locationManager.requestPermission()
    }
    
    private func setupGeohashListener() {
        GeohashService.shared.$currentLocation
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    self?.fetchNewData()
                }
            }
            .store(in: &cancellables)
    }
    
    
    
    // MARK: fetching
    
    private func fetchNewData(){
        if currentPrecision == .individuals {
            
        } else {
            Task {
                do {
                    try await fetchClusters(precision: currentPrecision)
                } catch {
                    showErrorMsgForClusters()
                }
                
            }
            
        }
    }
    private func fetchClusters(precision: GeohasPrecision) async throws {
        let queryPrecision = max(1, precision.rawValue - 1)
        let bounds = GeohashService.shared.calculateGeohashBounds(precision: queryPrecision)
        
        let repo = AvailabilityAggregateRepository()
        let query = createQuery(bounds: bounds!, repo: repo)
        var clusters = try await repo.fetch(query: query)
        
        await MainActor.run {
            clusters = clusters.filter{ $0.precision == precision.rawValue }
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
    
    // MARK: zooming to fit city
    func zoomToCity(center: CLLocationCoordinate2D? = nil) {
        let coordinate = center ?? locationManager.userLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: mapsHelper.cityZoomLatitudeDelta,
                    longitudeDelta: mapsHelper.cityZoomLongitudeDelta
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
        
        let region = mapsHelper.calculateRegion(for: coordinates)
        cameraPosition = .region(region)
    }
    
    
    
    private func showErrorMsgForClusters(){
        alertMsg = "Error fetching new clusters, please try again later"
        showErrorAlert = true
    }
    
}
