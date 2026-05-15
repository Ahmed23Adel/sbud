//
//  FiltersViewModel.swift
//  sbud
//
//  Created by ahmed on 29/12/2025.
//

import Foundation
import Combine
import SwiftUI
import Foundation
import Combine
import SwiftUI
import Foundation
import Combine
import SwiftUI

class FiltersViewModel: ObservableObject {
    let icons         = AvailabilityConfig.icons
    let activityNames = AvailabilityConfig.activityNames

    @Binding var availabilityFiltersResults: AvailabilityFiltersResults
    @Published var selectedActivityIndex: Int {
        didSet { availabilityFiltersResults.selectedActivityIndex = selectedActivityIndex }
    }

    /// Tracked by WheelContainer — drives the blur overlay
    @Published var isWheelBig: Bool = false

    var selectedActivityType: ActivityType {
        AvailabilityConfig.activityType(for: selectedActivityIndex)
    }

    init(availabilityFiltersResults: Binding<AvailabilityFiltersResults>) {
        self._availabilityFiltersResults = availabilityFiltersResults
        selectedActivityIndex = availabilityFiltersResults.wrappedValue.selectedActivityIndex
        
    }
}
