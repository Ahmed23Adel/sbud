//
//  EventRoleService.swift
//  sbud
//
//  Created by Erdal on 9.05.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum EventUserRole {
    case creator
    case acceptedHost
    case regularUser
}

class EventRoleService {

    static func getRole(eventId: String) async -> EventUserRole {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return .regularUser
        }

        let db = Firestore.firestore()

        do {
            let eventDoc = try await db.collection("Events").document(eventId).getDocument()
            if let creatorId = eventDoc.data()?["creatorId"] as? String,
               creatorId == currentUserId {
                return .creator
            }
        } catch {
            return .regularUser
        }

        do {
            let hostDoc = try await db
                .collection("Events").document(eventId)
                .collection("hosts").document(currentUserId)
                .getDocument()

            if hostDoc.exists,
               let status = hostDoc.data()?["status"] as? String,
               status == HostInvitationStatus.accepted.rawValue {
                return .acceptedHost
            }
        } catch {
            return .regularUser
        }

        return .regularUser
    }
}

