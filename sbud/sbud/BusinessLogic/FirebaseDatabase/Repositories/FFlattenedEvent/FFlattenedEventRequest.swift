//
//  FlattenedEventsRequest.swift
//  sbud
//
//  Created by ahmed on 26/01/2026.
//

import Foundation
import FirebaseFirestore

struct FlattenedEventsRequest {
    let selectedStartTime: Date
    let selectedEndTime: Date
    let topLeft: GeoPoint
    let bottomRight: GeoPoint
    let selectedActivityType: ActivityTypes
    let limit: Int
    let precision: Int
    
    init(
        selectedStartTime: Date,
        selectedEndTime: Date,
        topLeft: GeoPoint,
        bottomRight: GeoPoint,
        selectedActivityType: ActivityTypes,
        limit: Int = 1000,
        precision: Int = 5
    ) {
        self.selectedStartTime = selectedStartTime
        self.selectedEndTime = selectedEndTime
        self.topLeft = topLeft
        self.bottomRight = bottomRight
        self.selectedActivityType = selectedActivityType
        self.limit = limit
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
            "limit": limit,
            "precision": precision
        ]
        
        parameters["selectedActivityType"] = selectedActivityType.rawValue
        
        return parameters
    }
}


