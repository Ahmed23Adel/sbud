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
    case skiing = "Skiing"
    case swimming = "Swimming"
    case hiking = "Hiking"
    case yoga = "Yoga"
    case tennis = "Tennis"
    
    
    var icon: String {
        switch self {
        case .running:
            "figure.run"
        case .cycling:
            "figure.outdoor.cycle"
        case .gym:
            "dumbbell"
        case .skiing:
            "figure.skiing.crosscountry"
        case .swimming:
            "figure.pool.swim"
        case .hiking:
            "figure.hiking"
        case .yoga:
            "figure.yoga"
        case .tennis:
            "figure.tennis"
            
        }
    }
    
    var iconBaseName: String {
        switch self {
        case .running:
            "run"
        case .cycling:
            "gym"
        case .gym:
            "cycling"
        case .skiing:
            "run"
        case .swimming:
            "run"
        case .hiking:
            "run"
        case .yoga:
            "run"
        case .tennis:
            "run"
        }
    }
}

struct ActivityMetrics: Codable, Equatable {
    var averagePace: String?      // running
}

