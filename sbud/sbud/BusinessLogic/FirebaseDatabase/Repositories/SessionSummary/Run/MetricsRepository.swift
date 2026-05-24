//
//  MetricsRepository.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation
import FirebaseFirestore

class MetricsRepository: IMetricsRepository {

    private let db = Firestore.firestore()

    func fetchMetrics(eventId: String) async throws -> [MetricsCollectedRun] {
        let snapshot = try await db
            .collection("Events")
            .document(eventId)
            .collection("metrics")
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: MetricsCollectedRun.self)
        }
    }

    func fetchSessionHistory(eventId: String) async throws -> [SessionHistoryEntry] {
        let doc = try await db.collection("Events").document(eventId).getDocument()
        guard let data = doc.data(),
              let raw = data["sessionHistory"] as? [[String: Any]]
        else { return [] }

        return raw.enumerated().compactMap { index, entry in
            guard let start = (entry["startDateTime"] as? Timestamp)?.dateValue(),
                  let end   = (entry["endDateTime"]   as? Timestamp)?.dateValue()
            else { return nil }
            return SessionHistoryEntry(id: index, startDateTime: start, endDateTime: end)
        }
    }
}
