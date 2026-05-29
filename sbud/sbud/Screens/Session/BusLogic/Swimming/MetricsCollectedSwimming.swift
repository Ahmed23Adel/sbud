//
//  MetricsCollectedSwimming.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//


import Foundation
import FirebaseFirestore

struct MetricsCollectedSwimming: Codable {
    var userId = ProfileManager.shared.getLocalProfile()?.id
    var startDateTime: Date
    var endDateTime: Date
    var metricsCreatorType: MetricsCreatorType
    var endedBeforeCreator: Bool = false
    var numSession: Int
    
    
    struct MetricsCollectedGym: Codable {
        var userId: String          // ← add this
        var startDateTime: Date
        var endDateTime: Date
        var metricsCreatorType: MetricsCreatorType
        var endedBeforeCreator: Bool = false
        var numSession: Int
    }
}
