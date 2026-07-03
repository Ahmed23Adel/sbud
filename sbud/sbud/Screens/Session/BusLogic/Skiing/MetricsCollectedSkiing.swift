//
//  MetricsCollectedSkiing.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//


import Foundation
import FirebaseFirestore

struct MetricsCollectedSkiing: Codable {
    var userId = ProfileManager.shared.getLocalProfile()?.id
    var startDateTime: Date
    var endDateTime: Date
    var metricsCreatorType: MetricsCreatorType
    var track: [TrackPoint]
    var totalDistance: Double
    var verticalDrop: Double
    var elevationGain: Double
    var numberOfRuns: Int
    var splits: [SplitForSkiing]
    var endedBeforeCreator: Bool = false
    var numSession: Int
    
    func upload(eventId: String, userId: String) async throws {
        let db = Firestore.firestore()
        let data = try Firestore.Encoder().encode(self)
        try await db
            .collection("Events")
            .document(eventId)
            .collection("metrics")
            .addDocument(data: data)
    }
}
