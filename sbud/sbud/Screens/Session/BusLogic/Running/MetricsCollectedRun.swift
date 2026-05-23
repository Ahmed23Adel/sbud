//
//  MetricsCollectedRun.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import Foundation
import FirebaseFirestore

struct MetricsCollectedRun: Codable {
    var startDateTime: Date
    var endDateTime: Date
    var metricsCreatorType: MetricsCreatorType
    var track: [TrackPoint]
    var totalDistance: Double
    var splits: [Split]
    var endedBeforeCreator: Bool = false
    var numSession: Int

    func upload(eventId: String, userId: String) async throws {
        let db = Firestore.firestore()
        let docRef = db
            .collection("Events")
            .document(eventId)
            .collection("metrics")
            .document(userId)
        try docRef.setData(from: self)
    }
}
