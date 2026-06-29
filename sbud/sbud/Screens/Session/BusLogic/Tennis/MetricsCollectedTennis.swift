//
//  MetricsCollectedTennis.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import Foundation
import FirebaseFirestore

struct MetricsCollectedTennis: Codable {
    var userId = ProfileManager.shared.getLocalProfile()?.id
    var startDateTime: Date
    var endDateTime: Date
    var metricsCreatorType: MetricsCreatorType
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
