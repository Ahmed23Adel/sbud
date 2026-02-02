//
//  FiltersViewModel.swift
//  sbud
//
//  Created by ahmed on 29/12/2025.
//

import Foundation
import Combine
import SwiftUI

class FiltersViewModel: ObservableObject {
    let icons = AvailabilityConfig.icons
    let activityNames = AvailabilityConfig.activityNames
    @Binding var availabilityFiltersResults: AvailabilityFiltersResults
    @Published var selectedActivityIndex: Int {
        didSet {
            availabilityFiltersResults.selectedActivityIndex = selectedActivityIndex
        }
    }
    var selectedActivityName: String {
        activityNames[selectedActivityIndex]
    }

    var selectedActivityType: ActivityType {
        let index = availabilityFiltersResults.selectedActivityIndex
        let activityName = activityNames[index]
        switch activityName {
        case "Running":
            return .running
        case "Gym":
            return .gym
        case "Cycling":
            return .cycling
        default:
            return .running
        }
    }

    init(availabilityFiltersResults: Binding<AvailabilityFiltersResults>) {
        self._availabilityFiltersResults = availabilityFiltersResults
        selectedActivityIndex = availabilityFiltersResults.wrappedValue.selectedActivityIndex
    }

}
