//
//  SessionMetricsBase.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation

// MARK: - Common protocol all metric structs conform to

protocol SessionMetricsBase: Codable {
    var userId: String? { get }
    var startDateTime: Date { get }
    var endDateTime: Date { get }
    var metricsCreatorType: MetricsCreatorType { get }
    var endedBeforeCreator: Bool { get }
    var numSession: Int { get }
}

// MARK: - Conformances (all metric structs already have these fields)

extension MetricsCollectedRun:      SessionMetricsBase {}
extension MetricsCollectedCycling:  SessionMetricsBase {}
extension MetricsCollectedHiking:   SessionMetricsBase {}
extension MetricsCollectedSkiing:   SessionMetricsBase {}
extension MetricsCollectedGym:      SessionMetricsBase {}
extension MetricsCollectedYoga:     SessionMetricsBase {}
// Swimming & Tennis outer structs conform (inner nested struct is dead code)
extension MetricsCollectedSwimming: SessionMetricsBase {}
extension MetricsCollectedTennis:   SessionMetricsBase {}

// MARK: - Unified split for chart display (activity-agnostic)

struct DisplaySplit: Identifiable {
    var id = UUID()
    let number: Int
    let chartValue: Double   // pace (min/km) or speed (km/h)
    let displayText: String  // formatted for annotation
    let isSpeed: Bool        // true → higher is better; false → lower is better
}
