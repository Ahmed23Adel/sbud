//
//  NotificationsRepository.swift
//  sbud
//
//  Created by ahmed on 08/07/2026.
//

import Foundation
import FirebaseFirestore

final class NotificationsRepository {
    private let db = Firestore.firestore()
    private let eventsCollection = "Events"
    private let usersCollection = "users"

    func incrementUnreadMessages(eventId: String, recipientUserId: String) async throws {
        let batch = db.batch()
        batch.updateData(["unreadMessagesCount": FieldValue.increment(Int64(1))],
                          forDocument: db.collection(eventsCollection).document(eventId))
        batch.updateData(["unreadMessagesCount": FieldValue.increment(Int64(1))],
                          forDocument: db.collection(usersCollection).document(recipientUserId))
        try await batch.commit()
    }

    func decrementUnreadMessages(eventId: String, userId: String, by amount: Int) async throws {
        guard amount > 0 else { return }
        let batch = db.batch()
        batch.updateData(["unreadMessagesCount": FieldValue.increment(Int64(-amount))],
                          forDocument: db.collection(eventsCollection).document(eventId))
        batch.updateData(["unreadMessagesCount": FieldValue.increment(Int64(-amount))],
                          forDocument: db.collection(usersCollection).document(userId))
        try await batch.commit()
    }

    func incrementPendingRequests(eventId: String, creatorUserId: String) async throws {
        let batch = db.batch()
        batch.updateData(["pendingRequestsCount": FieldValue.increment(Int64(1))],
                          forDocument: db.collection(eventsCollection).document(eventId))
        batch.updateData(["pendingRequestsCount": FieldValue.increment(Int64(1))],
                          forDocument: db.collection(usersCollection).document(creatorUserId))
        try await batch.commit()
    }

    func decrementPendingRequests(eventId: String, creatorUserId: String) async throws {
        let batch = db.batch()
        batch.updateData(["pendingRequestsCount": FieldValue.increment(Int64(-1))],
                          forDocument: db.collection(eventsCollection).document(eventId))
        batch.updateData(["pendingRequestsCount": FieldValue.increment(Int64(-1))],
                          forDocument: db.collection(usersCollection).document(creatorUserId))
        try await batch.commit()
    }
}
