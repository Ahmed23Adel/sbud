//
//  MetricsRepository.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation
import FirebaseFirestore

class MetricsRepository: IFirebaesRepository, IMetricsRepository {

    // MARK: - IFirebaesRepository conformance

    typealias T = MetricsCollectedRun
    typealias Constants = MetricsRepositoryConstants

    let collectionPath = "metrics"
    let firebaseClient = FirebaseClient()
    let constants = MetricsRepositoryConstants()

    func fetch(query: any IQueryBuilder) async throws -> [MetricsCollectedRun] {
        let snapshot = try await query.build().getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: MetricsCollectedRun.self) }
    }

    func fetchById(_ id: String) async throws -> MetricsCollectedRun? {
        let snapshot = try await firebaseClient.db
            .collectionGroup(collectionPath)
            .whereField(FieldPath.documentID(), isEqualTo: id)
            .limit(to: 1)
            .getDocuments()
        return snapshot.documents.first.flatMap { try? $0.data(as: MetricsCollectedRun.self) }
    }

    func fetchByIds(_ ids: [String]) async throws -> [MetricsCollectedRun]? {
        guard !ids.isEmpty else { return [] }
        let results = try await withThrowingTaskGroup(of: MetricsCollectedRun?.self) { group in
            for id in ids {
                group.addTask { try await self.fetchById(id) }
            }
            var items: [MetricsCollectedRun] = []
            for try await item in group {
                if let item { items.append(item) }
            }
            return items
        }
        return results
    }

    func create(_ item: MetricsCollectedRun) async throws -> String {
        // Use MetricsCollectedRun.upload(eventId:userId:) for writes —
        // the subcollection path requires an eventId not available here.
        throw RepositoryError.operationNotSupported
    }

    func update(_ id: String, _ item: MetricsCollectedRun) async throws {
        // Metrics are append-only; updates not supported via this path.
        throw RepositoryError.operationNotSupported
    }

    func delete(_ id: String) async throws {
        // Metrics are append-only; deletions not supported via this path.
        throw RepositoryError.operationNotSupported
    }

    func initQueryBuilderObject() -> any IQueryBuilder {
        QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
    }

    // MARK: - IMetricsRepository — event-scoped queries

    func fetchMetrics(eventId: String) async throws -> [MetricsCollectedRun] {
        let snapshot = try await firebaseClient.db
            .collection("Events")
            .document(eventId)
            .collection(collectionPath)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: MetricsCollectedRun.self) }
    }

    func fetchSessionHistory(eventId: String) async throws -> [SessionHistoryEntry] {
        let doc = try await firebaseClient.db
            .collection("Events")
            .document(eventId)
            .getDocument()
        guard let data = doc.data(),
              let raw = data["sessionHistory"] as? [[String: Any]]
        else { return [] }

        return raw.enumerated().compactMap { index, entry in
            guard let start = (entry[constants.startDateTime] as? Timestamp)?.dateValue(),
                  let end   = (entry[constants.endDateTime]   as? Timestamp)?.dateValue()
            else { return nil }
            return SessionHistoryEntry(id: index, startDateTime: start, endDateTime: end)
        }
    }
}

// MARK: - Errors

enum RepositoryError: Error, LocalizedError {
    case operationNotSupported

    var errorDescription: String? {
        switch self {
        case .operationNotSupported:
            return "This operation is not supported for this repository."
        }
    }
}
