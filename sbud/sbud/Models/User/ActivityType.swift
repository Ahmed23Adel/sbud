//
//  ActivityType.swift
//  sbud
//
//  Created by Erdal on 23/12/2025.
//
enum ActivityType: String, Codable, CaseIterable {
    case running
    case cycling
    case football
}

struct ActivityMetrics: Codable, Equatable {
    var averagePace: String?      // running
    var averageSpeed: Double?     // cycling
    var goalsPerMatch: Int?       // football
}
