//
//  MetricsCollectedCycling.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import Foundation
import FirebaseFirestore

struct MetricsCollectedCycling: Codable {
    var startDateTime: Date
    var endDateTime: Date
    var metricsCreatorType: MetricsCreatorType
    var track: [TrackPoint]
    var totalDistance: Double
    var elevationGain: Double
    var splits: [SplitForCycling]
    var endedBeforeCreator: Bool = false

    func upload(eventId: String, userId: String) async throws {
        let db = Firestore.firestore()
        try db
            .collection("Events")
            .document(eventId)
            .collection("metrics")
            .document(userId)
            .setData(from: self)
    }
}
