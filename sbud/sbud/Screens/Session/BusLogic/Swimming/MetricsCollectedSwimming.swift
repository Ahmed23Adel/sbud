//
//  MetricsCollectedSwimming.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//


import Foundation
import FirebaseFirestore

struct MetricsCollectedSwimming: Codable {
    var startDateTime: Date
    var endDateTime: Date
    var metricsCreatorType: MetricsCreatorType
    var endedBeforeCreator: Bool = false
    var numSession: Int
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
