//
//  ViewModelSearchEvents.swift
//  sbud
//
//  Created by ahmed on 26/05/2026.
//

import Foundation
import SwiftUI
import MapKit
import FirebaseFirestore

@Observable
class ViewModelSearchEvents {
    var searchQuery: String = ""
    var searchResults: [SearchEventResult] = []
    var isLoading: Bool = false
    var showAlert: Bool = false
    var alertMsg: String = ""
    var currentPage: Int = 1
    var isLoadingNewPage: Bool = false
    var useFilters: Bool = false
    var hasNextPage: Bool = false

    private let requester = SearchEventRequester()
    private let pageSize = 20

    let region: MKCoordinateRegion
    let filterResults: AvailabilityFiltersResults?

    init(region: MKCoordinateRegion, filterResults: AvailabilityFiltersResults? = nil) {
        self.region = region
        self.filterResults = filterResults
        self.useFilters = filterResults != nil
    }

    @MainActor
    func performSearch() async {
        guard !searchQuery.isEmpty else {
            searchResults = []
            currentPage = 1
            return
        }

        isLoading = true
        currentPage = 1
        await search()
    }

    @MainActor
    func loadMoreResults() async {
        guard hasNextPage else { return }
        isLoadingNewPage = true
        currentPage += 1
        await search()
    }

    @MainActor
    private func search() async {
        let requestType: SearchEventRequestType

        if useFilters, let filters = filterResults {
            let topLeft = GeoPoint(
                latitude: region.center.latitude + region.span.latitudeDelta / 2,
                longitude: region.center.longitude - region.span.longitudeDelta / 2
            )
            let bottomRight = GeoPoint(
                latitude: region.center.latitude - region.span.latitudeDelta / 2,
                longitude: region.center.longitude + region.span.longitudeDelta / 2
            )

            let extraFilters = filters.buildExtraQueryParams()

            requestType = .filtered(
                topLeft: topLeft,
                bottomRight: bottomRight,
                activityType: filters.selectedActivity.rawValue,
                startTime: filters.startDateTime,
                endTime: filters.endDateTime,
                query: searchQuery,
                extraFilters: extraFilters,
                page: currentPage,
                pageSize: pageSize
            )
        } else {
            requestType = .basic(
                query: searchQuery,
                page: currentPage,
                pageSize: pageSize
            )
        }

        do {
            let response = try await requester.search(requestType: requestType)
            let results = response.events.map { $0.toSearchEventResult() }

            if currentPage == 1 {
                searchResults = results
            } else {
                searchResults.append(contentsOf: results)
            }

            hasNextPage = response.hasNext ?? false
            isLoading = false
            isLoadingNewPage = false
        } catch {
            alertMsg = "Failed to search events: \(error.localizedDescription)"
            showAlert = true
            isLoading = false
            isLoadingNewPage = false
        }
    }

    func toggleFilterMode() {
        useFilters.toggle()
        currentPage = 1
        searchResults = []
        if !searchQuery.isEmpty {
            Task {
                await performSearch()
            }
        }
    }
}
