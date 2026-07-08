//
//  JoinedEventsRepository.swift
//  sbud
//
//  Created by ahmed on 22/05/2026.
//


import Foundation
import FirebaseFirestore
import OSLog

class JoinedEventsRepository: IFirebaesRepository {
    typealias T = JoinedEvent
    typealias Constants = JoinedEventsRepositoryConstants

    let collectionPath = "joinedEvents"
    let firebaseClient = FirebaseClient()
    let constants = JoinedEventsRepositoryConstants()
    let db = Firestore.firestore()
    let logger = Logger(subsystem: "sBud", category: "JoinedEventsRepository")

    func fetch(query: any IQueryBuilder) async throws -> [JoinedEvent] {
        let queryRef = query.build()
        let snapshot = try await queryRef.getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: JoinedEvent.self)
        }
    }

    func fetchById(_ id: String) async throws -> JoinedEvent? {
        let doc = try await db.collection(collectionPath).document(id).getDocument()
        return try? doc.data(as: JoinedEvent.self)
    }

    func fetchByIds(_ ids: [String]) async throws -> [JoinedEvent]? {
        return []
    }

    @discardableResult
    func create(_ item: JoinedEvent) async throws -> String {
        let docRef = db.collection(collectionPath).document()
        try docRef.setData(from: item)
        return docRef.documentID
    }

    func update(_ id: String, _ item: JoinedEvent) async throws {
        try db.collection(collectionPath).document(id).setData(from: item, merge: true)
    }

    func delete(_ id: String) async throws {
        try await db.collection(collectionPath).document(id).delete()
    }

    func initQueryBuilderObject() -> any IQueryBuilder {
        QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
    }

    /// Fetches everyone who joined a given event (as a participant, not a host), ready for
    /// display as `UserProfile`s. Shared by every "who's joined this event" UI (event details,
    /// my events, others' events) so the query/logging logic lives in exactly one place.
    ///
    /// Note: `JoinedEvent.status` is the *event's* own Proposed/Confirmed/Completed lifecycle
    /// (see `ParticipatedEventsViewModel`/`EventReminderScheduler`), not whether this user's
    /// join was accepted — a `joinedEvents` doc existing at all means they joined, so it's not
    /// filtered on here. `participationStatus` is what distinguishes participants from hosts.
    func fetchParticipants(eventId: String) async -> [UserProfile] {
        logger.info("fetchParticipants eventId: \(eventId)")
        do {
            var query = initQueryBuilderObject()
            query = query.appendFilter(Filter(field: constants.eventId, operation: .isEqualTo, value: eventId))
            query = query.appendFilter(Filter(field: constants.participationStatus, operation: .isEqualTo, value: ParticipationStatus.participant.rawValue))
            let joinedEvents = try await fetch(query: query)
            logger.info("fetchParticipants eventId: \(eventId) results: \(joinedEvents)")
            return joinedEvents.map(\.asUserProfile)
        } catch {
            logger.error("fetchParticipants error eventId: \(eventId): \(error.localizedDescription)")
            return []
        }
    }
}
