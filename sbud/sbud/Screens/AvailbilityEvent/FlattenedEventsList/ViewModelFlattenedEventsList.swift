//
//  ViewModelFlattenedEventsList.swift
//  sbud
//
//  Created by ahmed on 08/02/2026.
//

import Foundation
import Combine
import _MapKit_SwiftUI

class ViewModelFlattenedEventsList: ObservableObject{
    let region: MKCoordinateRegion
    let filterResults: AvailabilityFiltersResults
    @Published var isLoading: Bool = true
    var currentPage = 1
    var pageSize = 10
    @Published var events: [Event] = []
    @Published var showAlert = false
    @Published var alertMsg = ""
    private var canLoadMore = true
    @Published var isLoadingNewPage = false
    
    init(region: MKCoordinateRegion, filterResults: AvailabilityFiltersResults) {
        print("ViewModelFlattenedEventsList1")
        self.region = region
        self.filterResults = filterResults
        loadInitialEvents()
        
    }
    
    private func loadInitialEvents() {
        isLoadingNewPage = true
        Task {
            print("ViewModelFlattenedEventsList12")
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
        print("ViewModelFlattenedEventsList3")
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
            let results = try await requester.fetchEvents(requestParams: requestParams)
            await MainActor.run {
                print("requestParams", requestParams.toDict())
                print("results.events", results.events.count)
                events.append(contentsOf: results.events)
                incPage()
                finishLoading()
                canLoadMore = results.hasNext
            }
            
        } catch {
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
