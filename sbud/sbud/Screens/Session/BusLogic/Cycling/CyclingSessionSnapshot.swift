//
//  CyclingSessionSnapshot.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//


import Foundation

struct CyclingSessionSnapshot: Codable {
    let eventId: String
    let startDate: Date
    let lastSplitDate: Date?
    let totalDistanceMeters: Double
    let distanceSinceLastSplit: Double
    let elevationGainMeters: Double
    let elapsedSeconds: Double
    let minSpeedKmH: Double
    let maxSpeedKmH: Double
    let splits: [SplitForCycling]
    let trackPoints: [TrackPoint]
}
