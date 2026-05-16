//
//  ViewModelHostsRequests.swift
//  sbud
//
//  Created by ahmed on 03/05/2026.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

struct HostInvitationItem: Identifiable {
    let id: String          // eventId
    let title: String
    let imageUrl: String?
    let invitedAt: Date
}

@MainActor
@Observable
class ViewModelHostsRequests {
    var invitations: [HostInvitationItem] = []
    var isLoading = false
    var errorMessage: String?

    private let db = Firestore.firestore()
    private let friendManager = FriendManager.shared

    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    func load() async {
        guard let uid = currentUserId else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let eventIds = try await friendManager.fetchHostsPendingRequests(userId: uid)

            var items: [HostInvitationItem] = []
            for eventId in eventIds {
                async let eventDoc = db.collection("Events").document(eventId).getDocument()
                async let inviteDoc = db
                    .collection("users").document(uid)
                    .collection("hostInvitations").document(eventId)
                    .getDocument()

                let (event, invite) = try await (eventDoc, inviteDoc)

                let title     = event.data()?["title"] as? String ?? "Untitled Event"
                let imageUrl  = event.data()?["eventImage"] as? String
                let invitedAt = (invite.data()?["invitedAt"] as? Timestamp)?.dateValue() ?? Date()

                items.append(HostInvitationItem(id: eventId, title: title, imageUrl: imageUrl, invitedAt: invitedAt))
            }
            invitations = items
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func accept(eventId: String) async { await respond(eventId: eventId, status: .accepted) }
    func decline(eventId: String) async { await respond(eventId: eventId, status: .rejected) }

    private func respond(eventId: String, status: HostInvitationStatus) async {
        guard let uid = currentUserId else { return }
        do {
            let batch = db.batch()
            let payload: [String: Any] = [
                "status": status.rawValue,
                "respondedAt": FieldValue.serverTimestamp()
            ]
            batch.updateData(payload, forDocument: db
                .collection("users").document(uid)
                .collection("hostInvitations").document(eventId))
            batch.updateData(payload, forDocument: db
                .collection("Events").document(eventId)
                .collection("hosts").document(uid))
            try await batch.commit()
            invitations.removeAll { $0.id == eventId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
