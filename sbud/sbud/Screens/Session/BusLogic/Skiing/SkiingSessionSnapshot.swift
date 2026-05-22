//
//  SkiingSessionSnapshot.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import Foundation

struct SkiingSessionSnapshot: Codable {
    let eventId: String
    let startDate: Date
    let lastSplitDate: Date?
    let totalDistanceMeters: Double
    let distanceSinceLastSplit: Double
    let elevationGainMeters: Double
    let verticalDropMeters: Double
    let numberOfRuns: Int
    let isDescending: Bool
    let elapsedSeconds: Double
    let maxSpeedKmH: Double
    let splits: [SplitForSkiing]
    let trackPoints: [TrackPoint]
}
