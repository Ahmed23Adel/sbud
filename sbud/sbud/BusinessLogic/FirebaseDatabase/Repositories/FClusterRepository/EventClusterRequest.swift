//
//  EventClusterModels.swift
//  sbud
//
//  Created by ahmed on 25/01/2026.
//

import Foundation
import FirebaseFirestore

struct EventClusterRequest {
    let selectedStartTime: Date
    let selectedEndTime: Date
    let topLeft: GeoPoint
    let bottomRight: GeoPoint
    let selectedActivityType: String?
    let precision: Int
    
    init(
        selectedStartTime: Date,
        selectedEndTime: Date,
        topLeft: GeoPoint,
        bottomRight: GeoPoint,
        selectedActivityType: String? = nil,
        precision: Int = 5
    ) {
        self.selectedStartTime = selectedStartTime
        self.selectedEndTime = selectedEndTime
        self.topLeft = topLeft
        self.bottomRight = bottomRight
        self.selectedActivityType = selectedActivityType
        self.precision = precision
    }
    
    // Convert to dictionary for Cloud Function call
    func toParameters() -> [String: Any] {
        var parameters: [String: Any] = [
            "selectedStartTime": ISO8601DateFormatter().string(from: selectedStartTime),
            "selectedEndTime": ISO8601DateFormatter().string(from: selectedEndTime),
            "topLeft": [
                "latitude": topLeft.latitude,
                "longitude": topLeft.longitude
            ],
            "bottomRight": [
                "latitude": bottomRight.latitude,
                "longitude": bottomRight.longitude
            ],
            "precision": precision
        ]
        
        if let activityType = selectedActivityType {
            parameters["selectedActivityType"] = activityType
        }
        
        return parameters
    }
}
