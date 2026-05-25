//
//  HikingSessionSnapshot.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import Foundation

struct HikingSessionSnapshot: Codable {
    let eventId: String
    let startDate: Date
    let lastSplitDate: Date?
    let totalDistanceMeters: Double
    let distanceSinceLastSplit: Double
    let elevationGainMeters: Double
    let elevationLossMeters: Double
    let maxAltitudeMeters: Double
    let currentAltitudeMeters: Double
    let elapsedSeconds: Double
    let splits: [SplitForHiking]
    let trackPoints: [TrackPoint]
}
