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
    
    
    private var currentRegion: MKCoordinateRegion?
    private var lastFetchedPrecision: GeohasPrecision?
        
    @Published var individualsAnchors: [AnchorAvailabilityEvent] = []
    
    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        requestPermissionForLocation()
        setupGeohashListener()
        setupCameraPositionListener()
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
    
    private func setupCameraPositionListener() {
        $cameraPosition
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main) // Wait for user to stop zooming
            .sink { [weak self] position in
                self?.handleCameraPositionChange(position)
            }
            .store(in: &cancellables)
    }
    
    private func handleCameraPositionChange(_ position: MapCameraPosition) {
        guard let region = position.region else { return }
        currentRegion = region
        let newPrecision = determinePrecision(from: region)
        
        print("📍 Camera changed -LatDelta: \(region.span.latitudeDelta), Precision: \(newPrecision)")
        
        if newPrecision != lastFetchedPrecision {
            currentPrecision = newPrecision
            shouldShowIndividuals = (newPrecision == .individuals)
            lastFetchedPrecision = newPrecision
            
            print("🔄 Precision changed from \(String(describing: lastFetchedPrecision)) to \(newPrecision)")
            print("👥 Should show individuals: \(shouldShowIndividuals)")
            
            fetchNewData()
        }
    }
    
    private func determinePrecision(from region: MKCoordinateRegion) -> GeohasPrecision {
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
    // MARK: fetching
    
    private func fetchNewData(){
        print("🎯 fetchNewData called - Precision: \(currentPrecision), ShowIndividuals: \(shouldShowIndividuals)")
        
        if currentPrecision == .individuals {
            Task {
                do {
                    shouldShowIndividuals = true
                    try await fetchIndividuals()
                } catch {
                    print("❌ Error fetching individuals: \(error)")
                    showErrorMsgForIndividuals()
                }
            }
        } else {
            Task {
                do {
                    try await fetchClusters(precision: currentPrecision)
                } catch {
                    print("❌ Error fetching clusters: \(error)")
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
    
    private func createQuery(bounds: (min: String, max: String), repo: AvailabilityAggregateRepository) -> IQueryBuilder {
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
    
    
    private func fetchIndividuals() async throws {
        print("👥 fetchIndividuals started")
        
        let queryPrecision = GeohasPrecision.neighbourhood.rawValue
        let repo = AvailabilityEventsRepository()
        var query = repo.initQueryBuilderObject()
        print("query", query)
        let bounds = GeohashService.shared.calculateGeohashBounds(precision: queryPrecision)
        
        print("🗺️ Geohash bounds - min: \(bounds?.min ?? "nil"), max: \(bounds?.max ?? "nil")")
        
        query = query.appendFilter(
            Filter(field: "g.geohash", operation: .isGreaterThanOrEqualTo, value: bounds!.min)
        )
        query = query.appendFilter(
            Filter(field: "g.geohash", operation: .isLessThan, value: bounds!.max)
        )
        query = query.setLimit(100)
        
        let events = try await repo.fetch(query: query)
        
        print("✅ Fetched \(events.count) individual events")
        
        await MainActor.run {
            self.individualsAnchors = events.map { AnchorAvailabilityEvent(event: $0) }
            self.anchorsClusters = [] // Clear clusters when showing individuals
            
            print("📌 individualsAnchors count: \(self.individualsAnchors.count)")
            print("📌 First few IDs: \(self.individualsAnchors.prefix(3).map { $0.id })")
        }
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
    
    private func showErrorMsgForIndividuals(){
        alertMsg = "Error fetching new availability events, please try again later"
        showErrorAlert = true
    }
    
    func handleMapCameraChange(_ region: MKCoordinateRegion) {
        currentRegion = region
        let newPrecision = determinePrecision(from: region)
        
        print("📍 Camera changed - LatDelta: \(region.span.latitudeDelta), Precision: \(newPrecision)")
        
        if newPrecision != lastFetchedPrecision {
            currentPrecision = newPrecision
            shouldShowIndividuals = (newPrecision == .individuals)
            lastFetchedPrecision = newPrecision
            
            print("🔄 Precision changed to \(newPrecision)")
            print("👥 Should show individuals: \(shouldShowIndividuals)")
            
            fetchNewData()
        }
    }
    
}
