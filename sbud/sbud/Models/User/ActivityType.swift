//
//  ActivityType.swift
//  sbud
//
//  Created by Erdal on 23/12/2025.
//
enum ActivityType: String, Codable, CaseIterable {
    case running
}

struct ActivityMetrics: Codable, Equatable {
    var averagePace: String?      // running
}
