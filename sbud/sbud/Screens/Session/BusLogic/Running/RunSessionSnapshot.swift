//
//  RunSessionSnapshot.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//


import Foundation
import CoreLocation

struct RunSessionSnapshot: Codable {
    let eventId: String
    let startDate: Date
    let lastSplitDate: Date?
    let totalDistanceMeters: Double
    let distanceSinceLastSplit: Double
    let elapsedSeconds: Double
    let minPace: Double
    let maxPace: Double
    let splits: [Split]
    let trackPoints: [TrackPoint]   // stored as TrackPoint (already Codable)

    // CLLocation isn't Codable so we store as TrackPoint and
    // reconstruct CLLocation on restore
}
