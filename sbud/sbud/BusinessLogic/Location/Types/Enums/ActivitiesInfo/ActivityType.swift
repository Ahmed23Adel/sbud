//
//  ActivityTypes.swift
//  sbud
//
//  Created by ahmed on 22/12/2025.
//

import Foundation

enum ActivityType: String, Codable, CaseIterable {
    case running = "Running"
    case cycling = "Cycling"
    case gym = "Gym"
    
    var icon: String {
        switch self {
        case .running:
            "figure.run"
        case .cycling:
            "figure.outdoor.cycle"
        case .gym:
            "dumbbell"
        }
    }
}
