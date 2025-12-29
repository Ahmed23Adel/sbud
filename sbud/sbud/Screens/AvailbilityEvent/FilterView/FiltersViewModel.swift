//
//  FiltersViewModel.swift
//  sbud
//
//  Created by ahmed on 29/12/2025.
//

import Foundation
import Combine

class FiltersViewModel: ObservableObject{
    let icons = AvailabilityConfig.icons
    let activityNames = AvailabilityConfig.activityNames
    private var availabilityFiltersResults: AvailabilityFiltersResults
    @Published var selectedActivityIndex: Int {
        didSet{
            availabilityFiltersResults.selectedActivityIndex = selectedActivityIndex
        }
    }
    var selectedActivityName: String {
        activityNames[selectedActivityIndex]
    }
    
    
    
    init(availabilityFiltersResults: AvailabilityFiltersResults){
        self.availabilityFiltersResults = availabilityFiltersResults
        selectedActivityIndex = availabilityFiltersResults.selectedActivityIndex
    }
    
}
