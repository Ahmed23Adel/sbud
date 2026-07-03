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
    let dataFetcher: AvailabilityDataFetching
    let mapsHelper: MapsHelper
    let locationProvider: LocationProviding
    private var cancellables = Set<AnyCancellable>()
    @Published var availabilityFiltersResults: AvailabilityFiltersResults
    private var selectedActivityIndex: Int = 0
    @Published var listViewRefreshId = UUID()
    private let logger = Logger(subsystem: "sBud", category: "AvailbilityViewModel")

    @Published var selectedTab = 0

    init(
        locationProvider: LocationProviding,
        availabilityFiltersResults: AvailabilityFiltersResults,
        dataFetcher: AvailabilityDataFetching = AvailabilityDataFetcher(),
        mapsHelper: MapsHelper = MapsHelper()
    ) {
        self.locationProvider = locationProvider
        self.availabilityFiltersResults = availabilityFiltersResults
        self.dataFetcher = dataFetcher
        self.mapsHelper = mapsHelper

        locationProvider.requestPermission()
        let coordinate = locationProvider.userLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
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
            Task { [weak self] in
                guard let self else { return }
                do {
                    shouldShowIndividuals = true
                    anchorAvailabilityEvents = try await dataFetcher.fetchIndividuals(
                        in: currentRegion!,
                        selectedStartDateTime: availabilityFiltersResults.startDateTime,
                        selectedEndDateTime: availabilityFiltersResults.endDateTime,
                        selectedActivityType: ActivityType(rawValue:
                            AvailabilityConfig.activityNames[selectedActivityIndex])
                            ?? .running,
                        extraFilters: availabilityFiltersResults.buildExtraQueryParams()
                    )
                    logger.debug("Fetching individuals: \(self.anchorsClusters.count)")
                    anchorsClusters.removeAll()
                } catch {
                    logger.fault("Couldn't load individuals events: \(error)")
                    showErrorMsgForIndividuals()
                }
            }
        } else {
            Task { [weak self] in
                guard let self else { return }
                do {
                    shouldShowIndividuals = false
                    anchorsClusters = try await dataFetcher.fetchClusters(
                        selectedStartTime: availabilityFiltersResults.startDateTime,
                        selectedEndTime: availabilityFiltersResults.endDateTime,
                        topLeft: currentRegion?.topLeft ?? GeoPoint(latitude: 0, longitude: 0),
                        bottomRight: currentRegion?.bottomRight ?? GeoPoint(latitude: 90, longitude: 180),
                        selectedActivityType: ActivityType(rawValue: AvailabilityConfig.activityNames[selectedActivityIndex])
                            ?? .running,
                        extraFilters: availabilityFiltersResults.buildExtraQueryParams()
                    )
                    logger.debug("Fetching clusters")
                    anchorAvailabilityEvents.removeAll()
                } catch {
                    showErrorMsgForClusters()
                }
            }
        }
    }

    // MARK: - Camera

    func zoomToCity(center: CLLocationCoordinate2D? = nil) {
        let coordinate = center ?? locationProvider.userLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
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

        currentRegion = region
        currentCameraPrecision = newPrecision
        lastFetchedPrecision = newPrecision

        if shouldFetch {
            logger.debug("Fetching new data")
            fetchNewData()
        }
    }

    // MARK: - Filters

    func changeSelectedActivity(selectedActivityIndex: Int) {
        self.selectedActivityIndex = selectedActivityIndex
        fetchNewData()
    }

    func updateListId() {
        listViewRefreshId = UUID()
    }

    private func setupFilterResultsListener() {
        availabilityFiltersResults.$selectedActivityIndex
            .sink { [weak self] newIndex in
                self?.changeSelectedActivity(selectedActivityIndex: newIndex)
            }
            .store(in: &cancellables)

        availabilityFiltersResults.$startDateTime
            .dropFirst()
            .sink { [weak self] _ in self?.fetchNewData() }
            .store(in: &cancellables)

        availabilityFiltersResults.$endDateTime
            .dropFirst()
            .sink { [weak self] _ in self?.fetchNewData() }
            .store(in: &cancellables)

        availabilityFiltersResults.$gender
            .dropFirst()
            .sink { [weak self] _ in self?.fetchNewData() }
            .store(in: &cancellables)

        subscribeToFilterHolder(availabilityFiltersResults.runningFilter)
        subscribeToFilterHolder(availabilityFiltersResults.cyclingFilter)
        subscribeToFilterHolder(availabilityFiltersResults.gymFilter)
        subscribeToFilterHolder(availabilityFiltersResults.skiingFilter)
        subscribeToFilterHolder(availabilityFiltersResults.swimmingFilter)
        subscribeToFilterHolder(availabilityFiltersResults.hikingFilter)
        subscribeToFilterHolder(availabilityFiltersResults.yogaFilter)
        subscribeToFilterHolder(availabilityFiltersResults.tennisFilter)
    }

    private func subscribeToFilterHolder<T: ObservableObject>(_ holder: T) {
        holder.objectWillChange
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.fetchNewData() }
            .store(in: &cancellables)
    }

    // MARK: - Errors

    private func showErrorMsgForClusters() {
        if !showErrorAlert {
            alertMsg = "Error fetching new clusters, please try again later"
            showErrorAlert = true
        }
    }

    private func showErrorMsgForIndividuals() {
        if !showErrorAlert {
            alertMsg = "Error fetching new availability events, please try again later"
            showErrorAlert = true
        }
    }
}
