//
//  AvailabilityFiltersResults.swift
//  sbud
//
//  Created by ahmed on 29/12/2025.
//

import Foundation
import Combine

class AvailabilityFiltersResults: ObservableObject {
    @Published var selectedActivityIndex = 0
    @Published var startDateTime = Date()
    @Published var endDateTime = Calendar.current.date(byAdding: .hour, value: 5, to: Date()) ?? Date()
    
    var selectedActivity: ActivityType {
        if selectedActivityIndex == 0 {
            return .running
        } else if selectedActivityIndex == 1 {
            return .cycling
        } else {
            return .gym
        }
    }
}
