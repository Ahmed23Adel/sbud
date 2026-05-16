//
//  UserHostInvitationsRepository.swift
//  sbud
//
//  Created by ahmed on 02/05/2026.
//
import Foundation
import FirebaseFirestore
import OSLog

class UserHostInvitationsRepository: IFirebaesRepository {
    typealias T = HostInvitation
    typealias Constants = HostRepositoryConstants

    var collectionPath: String
    let firebaseClient = FirebaseClient()
    let constants = HostRepositoryConstants()
    let logger = Logger(subsystem: "sbud", category: "UserHostInvitationsRepository")

    private let eventId: String

    init(targetUserId: String, eventId: String) {
        self.eventId = eventId
        self.collectionPath = "users/\(targetUserId)/hostInvitations"
    }

    func create(_ item: HostInvitation) async throws -> String {
        let data: [String: Any] = [
            "status": item.status.rawValue,
            "invitedAt": FieldValue.serverTimestamp(),
            "eventId": eventId
        ]
        try await firebaseClient.db
            .collection(collectionPath)
            .document(eventId)
            .setData(data)
        return eventId
    }

    func delete(_ id: String) async throws {
        try await firebaseClient.db
            .collection(collectionPath)
            .document(id)
            .delete()
    }

    // MARK: - Unused protocol stubs
    func fetch(query: any IQueryBuilder) async throws -> [HostInvitation] { [] }
    func fetchById(_ id: String) async throws -> HostInvitation? { nil }
    func fetchByIds(_ ids: [String]) async throws -> [HostInvitation]? { nil }
    func update(_ id: String, _ item: HostInvitation) async throws {}
    func initQueryBuilderObject() -> any IQueryBuilder {
        QueryCollectionBuilder(collectionPath: collectionPath, firebaseClient: firebaseClient)
    }
}
