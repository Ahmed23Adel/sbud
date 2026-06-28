//
//  HostsRepository.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import OSLog

class HostsRepository: IFirebaesRepository{
    typealias T = HostInvitation
    typealias Constants = HostRepositoryConstants
    
    var collectionPath = "Events"
    let firebaseClient = FirebaseClient()
    let constants = HostRepositoryConstants()
    let db = Firestore.firestore()
    let logger = Logger(subsystem: "sbud", category: "HostsRepository")
    let eventId: String
    let userId: String
    
    init(eventId: String){
        collectionPath = "\(collectionPath)/\(eventId)/hosts"
        self.eventId = eventId
        userId = ProfileManager.shared.getLocalProfile()!.id
        
        logger.info("Current collection path: \(self.collectionPath)")
    }
    
    func fetch(query: any IQueryBuilder) async throws -> [HostInvitation] {
        let queryRef = query.build()
        let snapshot = try await queryRef.getDocuments()
        let documents = snapshot.documents
        
        let hostsInvitations = documents.compactMap { doc -> HostInvitation? in
            let data = doc.data()
            let id = doc.documentID
            guard let invitedAt = data["invitedAt"] as? Timestamp,
                  let status = data["status"] as? String else {
                return nil
            }
            return HostInvitation(
                invitedAt: invitedAt.dateValue(),
                status: HostInvitationStatus(rawValue: status)!,
                userId: id
            )
        }
        return hostsInvitations
    }
    
    func fetchById(_ id: String) async throws -> HostInvitation? {
        return nil
    }
    
    func fetchByIds(_ ids: [String]) async throws -> [HostInvitation]? {
        return []
    }
    
    func create(_ item: HostInvitation) async throws -> String {
        let data: [String: Any] = [
            "status": item.status.rawValue,
            "invitedAt": FieldValue.serverTimestamp(),
        ]
        try await firebaseClient.db
            .collection(collectionPath)
            .document(item.userId)
            .setData(data)
        return item.userId
    }
    
    func update(_ id: String, _ item: HostInvitation) async throws {
        let data: [String: Any] = [
            "status": item.status.rawValue,
            "respondedAt": FieldValue.serverTimestamp()
        ]
        try await firebaseClient.db
            .collection(collectionPath)
            .document(id)
            .updateData(data)
    }
    
    func delete(_ id: String) async throws {
        try await firebaseClient.db
            .collection(collectionPath)
            .document(id)
            .delete()
    }
    
    func initQueryBuilderObject() -> any IQueryBuilder {
        QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
    }
    
    func inviteHost(_ invitation: HostInvitation) async throws {
        let batch = firebaseClient.db.batch()

        let eventHostRef = firebaseClient.db
            .collection(collectionPath)
            .document(invitation.userId)

        let userInviteRef = firebaseClient.db
            .collection("users")
            .document(invitation.userId)
            .collection("hostInvitations")
            .document(eventId)

        logger.info("eventHostRef path: \(eventHostRef.path)")
        logger.info("userInviteRef path: \(userInviteRef.path)")
        let inviteData: [String: Any] = [
            "status": HostInvitationStatus.pending.rawValue,
            "invitedAt": FieldValue.serverTimestamp(),
        ]

        let userInviteData: [String: Any] = [
            "status": HostInvitationStatus.pending.rawValue,
            "invitedAt": FieldValue.serverTimestamp(),
        ]

        batch.setData(inviteData, forDocument: eventHostRef)
        batch.setData(userInviteData, forDocument: userInviteRef)

        try await batch.commit()
    }

    func removeInvitation(targetUserId: String) async throws {
        let batch = firebaseClient.db.batch()

        let eventHostRef = firebaseClient.db
            .collection(collectionPath)
            .document(targetUserId)

        let userInviteRef = firebaseClient.db
            .collection("users")
            .document(targetUserId)
            .collection("hostInvitations")
            .document(eventId)

        batch.deleteDocument(eventHostRef)
        batch.deleteDocument(userInviteRef)

        try await batch.commit()

        let repo = JoinedEventsRepository()
        let joinedEventsSnap = try await db.collection("joinedEvents")
            .whereField(repo.constants.userId, isEqualTo: targetUserId)
            .whereField(repo.constants.eventId, isEqualTo: eventId)
            .whereField(repo.constants.participationStatus, isEqualTo: ParticipationStatus.host.rawValue)
            .getDocuments()

        for doc in joinedEventsSnap.documents {
            try await doc.reference.delete()
        }

        logger.info("Removed host \(targetUserId) from event \(self.eventId) including joinedEvents")
    }
}
