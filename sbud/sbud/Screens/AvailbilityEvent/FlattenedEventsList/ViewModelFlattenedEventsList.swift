//
//  ViewModelFlattenedEventsList.swift
//  sbud
//
//  Created by ahmed on 08/02/2026.
//

import Foundation
import Combine
import _MapKit_SwiftUI
import OSLog

@Observable
class ViewModelFlattenedEventsList{
    let region: MKCoordinateRegion
    let filterResults: AvailabilityFiltersResults
    var isLoading: Bool = true
    var currentPage = 1
    var pageSize = 10
    var events: [PaginatedEvent] = []
    var showAlert = false
    var alertMsg = ""
    private var canLoadMore = true
    var isLoadingNewPage = false
    let logger = Logger(subsystem: "sBud", category: "ViewModelFlattenedEventsList")
    
    init(region: MKCoordinateRegion, filterResults: AvailabilityFiltersResults) {
        self.region = region
        self.filterResults = filterResults
        loadInitialEvents()
        
    }
    
    private func loadInitialEvents() {
        isLoadingNewPage = true
        Task {
            await loadEvents()
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func finishLoading(){
        isLoading = false
        isLoadingNewPage = false
    }
    
    func loadEventsPaginnated(){
        if canLoadMore{
            Task {
                await loadEvents()
            }
        }
    }
    
    private func loadEvents() async{
        canLoadMore = false
        let requester = PaginatedFlattenedEventsRequester()
        do {
            let requestParams = PaginatedFlattenedEventsRequest(
                topLeft: region.topLeft,
                bottomRight: region.bottomRight,
                selectedActivityType: filterResults.selectedActivity.rawValue,
                selectedStartTime: filterResults.startDateTime,
                selectedEndTime: filterResults.endDateTime,
                page: currentPage,
                pageSize: pageSize
            )
            logger.info("requestParamslist \(requestParams.toDict())")
            let results = try await requester.fetchEvents(requestParams: requestParams)
            
            await MainActor.run {
                logger.notice("results \(results.events.count)")
                events.append(contentsOf: results.events)
                incPage()
                finishLoading()
                canLoadMore = results.hasNext
            }
            
        } catch {
            logger.error("error For requesting list \(error)")
            await MainActor.run {
                showError()
                canLoadMore = false
            }
        }
            
    }
    
    private func showError(){
        showAlert = true
        alertMsg = "Error with fetching the events, please try again later"
    }
    
    private func incPage(){
        currentPage += 1
    }
}
