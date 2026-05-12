//
//  Config.swift
//  sbud
//
//  Created by ahmed on 29/12/2025.
//

import Foundation

import Foundation

class AvailabilityConfig {
    static let icons: [String] = [
        "figure.run",
        "figure.outdoor.cycle",
        "dumbbell",
        "figure.skiing.downhill",
        "figure.pool.swim",
        "figure.hiking",
        "figure.yoga",
        "figure.tennis"
    ]

    static let activityNames: [String] = [
        "Running",
        "Cycling",
        "Gym",
        "Skiing",
        "Swimming",
        "Hiking",
        "Yoga",
        "Tennis"
    ]

    static func activityType(for index: Int) -> ActivityType {
        switch index {
        case 0: return .running
        case 1: return .cycling
        case 2: return .gym
        case 3: return .skiing
        case 4: return .swimming
        case 5: return .hiking
        case 6: return .yoga
        case 7: return .tennis
        default: return .running
        }
    }
}
