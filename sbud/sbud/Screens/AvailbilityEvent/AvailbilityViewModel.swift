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
import OSLog

final class AvailbilityViewModel: ObservableObject {
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var shouldShowIndividuals: Bool = false
    @Published var alertMsg = ""
    @Published var showErrorAlert = false
    @Published var anchorsClusters: [AnchorCluster] = []
    @Published var anchorAvailabilityEvents: [AnchorAvailabilityEvent] = []
    var currentCameraPrecision: GeohashPrecision = .neighbourhood
    var desiredDataPrecision: GeohashPrecision = .neighbourhood
    @Published var currentRegion: MKCoordinateRegion?
    private var lastFetchedPrecision: GeohashPrecision?
    let dataFetcher = AvailabilityDataFetcher()
    let mapsHelper = MapsHelper()
    var locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    @Published var availabilityFiltersResults: AvailabilityFiltersResults
    private var selectedActivityIndex: Int = 0
    @Published var listViewRefreshId = UUID()
    private let logger = Logger(subsystem: "sBud", category: "AvailbilityViewModel")

    
    @Published var selectedTab = 0
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
        fetchNewData()

    }

    private func fetchNewData() {

        if currentCameraPrecision == .individuals {
            Task {
                do {
                    shouldShowIndividuals = true
                    anchorAvailabilityEvents =  try await dataFetcher.fetchIndividuals(
                        in: currentRegion!,
                        selectedStartDateTime: availabilityFiltersResults.startDateTime,
                        selectedEndDateTime: availabilityFiltersResults.endDateTime,
                        selectedActivityType: ActivityType(rawValue:
                                                            AvailabilityConfig.activityNames[selectedActivityIndex])
                        ?? .running

                    )
                    logger.debug("Fetching individuals: \(self.anchorsClusters.count)")
                    anchorsClusters.removeAll()
                } catch {
                    logger.fault("Couldn't load individuals events: \(error)")
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
                        selectedActivityType: ActivityType(rawValue: AvailabilityConfig.activityNames[selectedActivityIndex])
                        ?? .running

                    )
                    logger.debug("Fetching clusters")
                    anchorAvailabilityEvents.removeAll()
                } catch {
                    showErrorMsgForClusters()
                }
            }
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

    // MARK: error msgs
    private func showErrorMsgForClusters() {
        if !showErrorAlert{
            alertMsg = "Error fetching new clusters, please try again later"
            showErrorAlert = true
        }
        
    }

    private func showErrorMsgForIndividuals() {
        if !showErrorAlert{
            alertMsg = "Error fetching new availability events, please try again later"
            showErrorAlert = true
        }
        
    }

    // MARK: GUI Camera change handeler
    func handleMapCameraChange(_ region: MKCoordinateRegion) {
        let newPrecision = mapsHelper.determinePrecision(from: region)
        logger.notice("Precision: \(newPrecision.rawValue), Last: \(self.lastFetchedPrecision?.rawValue ?? -1)")

        shouldShowIndividuals = (newPrecision == .individuals)

        guard let oldRegion = currentRegion else {
            currentRegion = region
            currentCameraPrecision = newPrecision
            lastFetchedPrecision = newPrecision
            fetchNewData()
            return
        }

        let shouldFetch: Bool
        if newPrecision == .individuals {
            shouldFetch = (lastFetchedPrecision != .individuals)
        } else {
            shouldFetch = !mapsHelper.isNewRegionContained(new: region, old: oldRegion)
        }
        if shouldFetch {
            logger.debug("Fetching new data")
            currentRegion = region
            currentCameraPrecision = newPrecision
            lastFetchedPrecision = newPrecision
            fetchNewData()
        } else {
            logger.debug("No fetch needed - region contained or already showing same data")
            currentRegion = region
            currentCameraPrecision = newPrecision
            lastFetchedPrecision = newPrecision
        }
    }

    // MARK: Filters
    private func setupFilterResultsListener() {
        availabilityFiltersResults.$selectedActivityIndex
            .sink { [weak self] newIndex in
                self?.changeSelectedActivity(selectedActivityIndex: newIndex)
            }
            .store(in: &cancellables)
    }

    func changeSelectedActivity(selectedActivityIndex: Int) {
        self.selectedActivityIndex = selectedActivityIndex
        fetchNewData()
    }
    
    func updateListId(){
        listViewRefreshId = UUID()
    }

}
