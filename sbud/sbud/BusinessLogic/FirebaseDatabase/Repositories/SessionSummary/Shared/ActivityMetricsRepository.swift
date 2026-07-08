//
//  ActivityMetricsRepository.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation
import FirebaseFirestore

// MARK: - Constants

struct ActivityMetricsRepositoryConstants: IRepositoryConstants {
    let startDateTime = "startDateTime"
    let endDateTime   = "endDateTime"
    let numSession    = "numSession"
    let userId        = "userId"
}

// MARK: - Generic repository (one class for all activities)

class ActivityMetricsRepository<Metric: SessionMetricsBase>: IFirebaesRepository {

    typealias T = Metric
    typealias Constants = ActivityMetricsRepositoryConstants

    let collectionPath = "metrics"
    let firebaseClient = FirebaseClient()
    let constants = ActivityMetricsRepositoryConstants()

    // MARK: - IFirebaesRepository

    func fetch(query: any IQueryBuilder) async throws -> [Metric] {
        let snapshot = try await query.build().getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Metric.self) }
    }

    func fetchById(_ id: String) async throws -> Metric? {
        let snapshot = try await firebaseClient.db
            .collectionGroup(collectionPath)
            .whereField(FieldPath.documentID(), isEqualTo: id)
            .limit(to: 1)
            .getDocuments()
        return snapshot.documents.first.flatMap { try? $0.data(as: Metric.self) }
    }

    func fetchByIds(_ ids: [String]) async throws -> [Metric]? {
        guard !ids.isEmpty else { return [] }
        return try await withThrowingTaskGroup(of: Metric?.self) { group in
            for id in ids { group.addTask { try await self.fetchById(id) } }
            var items: [Metric] = []
            for try await item in group { if let item { items.append(item) } }
            return items
        }
    }

    func create(_ item: Metric) async throws -> String {
        throw RepositoryError.operationNotSupported
    }

    func update(_ id: String, _ item: Metric) async throws {
        throw RepositoryError.operationNotSupported
    }

    func delete(_ id: String) async throws {
        throw RepositoryError.operationNotSupported
    }

    func initQueryBuilderObject() -> any IQueryBuilder {
        QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
    }

    // MARK: - Event-scoped reads

    func fetchMetrics(eventId: String) async throws -> [Metric] {
        let snapshot = try await firebaseClient.db
            .collection("Events")
            .document(eventId)
            .collection(collectionPath)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Metric.self) }
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
