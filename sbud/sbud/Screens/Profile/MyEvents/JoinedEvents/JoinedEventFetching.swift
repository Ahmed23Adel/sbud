//
//  JoinedEventFetching.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import Foundation
import FirebaseFirestore
protocol JoinedEventsFetching {
    func fetchJoinedEvents(userId: String) async throws -> [UsersEvent]
}
final class FirestoreJoinedEventsFetcher: JoinedEventsFetching {
    func fetchJoinedEvents(userId: String) async throws -> [UsersEvent] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("joinedEvents")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        return snapshot.documents.compactMap { doc -> UsersEvent? in
            let data = doc.data()
            guard let rawStatus = data["status"] as? String,
                  let status = UsersEventStatus(rawValue: rawStatus) else { return nil }
            var event = UsersEvent()
            event.eventId    = data["eventId"]    as? String ?? doc.documentID
            event.title      = data["title"]      as? String ?? ""
            event.eventImage = data["eventImage"] as? String ?? ""
            event.status     = status
            if let raw = data["activityType"] as? String {
                event.activityType = ActivityType(rawValue: raw) ?? .running
            }
            return event
        }
    }
}
