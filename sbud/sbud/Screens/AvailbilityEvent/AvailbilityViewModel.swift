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
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var shouldShowIndividuals: Bool = false
    @Published var alertMsg = ""
    @Published var showErrorAlert = false
    @Published var anchorsClusters: [AnchorCluster] = []
    @Published var anchorAvailabilityEvents: [AnchorAvailabilityEvent] = []
    var currentCameraPrecision: GeohashPrecision = .neighbourhood
    var desiredDataPrecision: GeohashPrecision = .neighbourhood
    private var currentRegion: MKCoordinateRegion?
    private var lastFetchedPrecision: GeohashPrecision?
    let dataFetcher = AvailabilityDataFetcher()
    let mapsHelper = MapsHelper()
    var locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    private var availabilityFiltersResults: AvailabilityFiltersResults
    private var selectedActivityIndex: Int = 0
    
    init(locationManager: LocationManager, availabilityFiltersResults: AvailabilityFiltersResults) {
        self.locationManager = locationManager
        self.availabilityFiltersResults = availabilityFiltersResults
        
        locationManager.requestPermission()
        let coordinate = locationManager.userLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        self.cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: mapsHelper.cityZoomLatitudeDelta,
                    longitudeDelta: mapsHelper.cityZoomLongitudeDelta
                )
            )
        )
        
        setupFilterResultsListener()
        setupListeners()
        fetchNewData()
        
    }
    
    private func setupListeners(){
        setupGeohashListener()
        setupCameraPositionListener()
    }
    
    
    // I should fetch near to users' location only
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
    
    
    private func fetchNewData(){
        
        if currentCameraPrecision == .individuals {
            Task {
                do {
                    shouldShowIndividuals = true
                    anchorAvailabilityEvents =  try await dataFetcher.fetchIndividuals(
                        in: currentRegion!,
                        selectedStartDateTime: availabilityFiltersResults.startDateTime,
                        selectedEndDateTime: availabilityFiltersResults.endDateTime,
                        selectedActivityType: ActivityTypes(rawValue: AvailabilityConfig.activityNames[selectedActivityIndex]) ?? .running
                        
                    )
                    print("region", currentRegion?.topLeft, currentRegion?.bottomRight, AvailabilityConfig.activityNames[selectedActivityIndex], availabilityFiltersResults.startDateTime, availabilityFiltersResults.endDateTime)
                    print("anchorAvailabilityEvents", anchorAvailabilityEvents)
                    anchorsClusters.removeAll()
                } catch {
                    print("erroridie", error)
                    showErrorMsgForIndividuals()
                }
            }
        } else {
            Task {
                do {
                    shouldShowIndividuals = false
                    anchorsClusters =  try await dataFetcher.fetchClusters(
                        selectedStartTime: availabilityFiltersResults.startDateTime,
                        selectedEndTime: availabilityFiltersResults.endDateTime,
                        topLeft: currentRegion?.topLeft ?? GeoPoint(latitude: 0, longitude: 0),
                        bottomRight: currentRegion?.bottomRight ?? GeoPoint(latitude: 180, longitude: 180),
                        selectedActivityType: ActivityTypes(rawValue: AvailabilityConfig.activityNames[selectedActivityIndex]) ?? .running
                        

                    )
                    anchorAvailabilityEvents.removeAll()
                } catch {
                    print("error", error)
                    showErrorMsgForClusters()
                }
            }
        }
    }
    
    private func handleCameraPositionChange(_ position: MapCameraPosition) {
        guard let region = position.region else { return }
        currentRegion = region
        let newPrecision = mapsHelper.determinePrecision(from: region)
        if newPrecision != lastFetchedPrecision {
            currentCameraPrecision = newPrecision
            shouldShowIndividuals = (newPrecision == .individuals)
            lastFetchedPrecision = newPrecision
            fetchNewData()
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
    
    
    // MARK: error msgs
    private func showErrorMsgForClusters(){
        alertMsg = "Error fetching new clusters, please try again later"
        showErrorAlert = true
    }
    
    private func showErrorMsgForIndividuals(){
        alertMsg = "Error fetching new availability events, please try again later"
        showErrorAlert = true
    }
    
    
    // MARK: GUI Camera change handeler
    func handleMapCameraChange(_ region: MKCoordinateRegion) {
        currentRegion = region
        let newPrecision = mapsHelper.determinePrecision(from: region)
        if newPrecision != lastFetchedPrecision {
            currentCameraPrecision = newPrecision
            shouldShowIndividuals = (newPrecision == .individuals)
            lastFetchedPrecision = newPrecision
            fetchNewData()
        }
    }
    
    // MARK: Filters
    private func setupFilterResultsListener(){
        availabilityFiltersResults.$selectedActivityIndex
            .sink{ [weak self] newIndex in
                self?.changeSelectedActivity(selectedActivityIndex: newIndex)
            }
            .store(in: &cancellables)
    }
    
    func changeSelectedActivity(selectedActivityIndex: Int){
        self.selectedActivityIndex = selectedActivityIndex
        fetchNewData()
    }
}
