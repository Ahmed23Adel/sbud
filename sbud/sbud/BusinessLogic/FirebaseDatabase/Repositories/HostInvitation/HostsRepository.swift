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
    
    init(eventId: String){
        collectionPath = "\(collectionPath)/\(eventId)/hosts"
        logger.info("Current collection path: \(self.collectionPath)")
    }
    
    func fetch(query: any IQueryBuilder) async throws -> [HostInvitation] {
        let queryRef = query.build()
        let snapshot = try await queryRef.getDocuments()
        let documents = snapshot.documents
        
        let hostsInvitations = documents.compactMap { doc -> HostInvitation? in
            let data = doc.data()
            let id = doc.documentID
            guard let invitedAt = data["invitedAt"] as? Date,
                  let status = data["status"] as? String else {
                return nil
            }
            return HostInvitation(
                invitedAt: invitedAt,
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
        ""
    }
    
    func update(_ id: String, _ item: HostInvitation) async throws {
        
    }
    
    func delete(_ id: String) async throws {
        
    }
    
    func initQueryBuilderObject() -> any IQueryBuilder {
        QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
    }
    
    
    
    
}
