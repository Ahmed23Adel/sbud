//
//  JoinEventRequester.swift
//  sbud
//
//  Created by Erdal on 3.05.2026.
//

import Foundation
import AdelsonAuthManager
import AdelsonApiCaller
internal import Alamofire

nonisolated struct JoinEventResponse: Decodable, Sendable {
    var status: String        // "pending" | "waitlisted"
    var message: String
}

nonisolated struct WithdrawResponse: Decodable, Sendable {
    var status: String
    var message: String
}

nonisolated struct LeaveResponse: Decodable, Sendable {
    var status: String
    var message: String
}

nonisolated struct JoinRespondBody: Encodable, Sendable {
    var requesterId: String
    var accept: Bool
}

nonisolated struct JoinRespondResponse: Decodable, Sendable {
    var status: String
    var message: String
}

nonisolated struct PendingRequester: Decodable, Identifiable, Sendable {
    var userId: String
    var name: String
    var surName: String
    var profileImageUrl: String?
    var id: String { userId }
    var fullName: String { "\(name) \(surName)".trimmingCharacters(in: .whitespaces) }
}

nonisolated struct JoinQueueResponse: Decodable, Sendable {
    var confirmedCount: Int
    var pendingCount: Int
    var waitlistCount: Int
    var capacity: Int?
    var isCapacityFull: Bool
    var waitlistMax: Int
    var pendingUsers: [PendingRequester]
}

nonisolated struct MyStatusResponse: Decodable, Sendable {
    var status: String
    var waitlistPosition: Int?
}

class JoinEventRequester {

    func joinEvent(eventId: String) async throws -> JoinEventResponse {
        let caller = AdelsonFirebaseApiCaller<JoinEventResponse>()
        return try await caller.call(
            url: "events/\(eventId)/join",
            params: EmptyBody(),
            method: .post,
            config: AdelsonFirebaseAuthConfig.shared
        )
    }

    func withdraw(eventId: String) async throws -> WithdrawResponse {
        let caller = AdelsonFirebaseApiCaller<WithdrawResponse>()
        return try await caller.call(
            url: "events/\(eventId)/withdraw",
            params: EmptyBody(),
            method: .post,
            config: AdelsonFirebaseAuthConfig.shared
        )
    }

    func leave(eventId: String) async throws -> LeaveResponse {
        let caller = AdelsonFirebaseApiCaller<LeaveResponse>()
        return try await caller.call(
            url: "events/\(eventId)/leave",
            params: EmptyBody(),
            method: .post,
            config: AdelsonFirebaseAuthConfig.shared
        )
    }

    func getPendingQueue(eventId: String) async throws -> JoinQueueResponse {
        let caller = AdelsonFirebaseApiCaller<JoinQueueResponse>()
        return try await caller.callGet(
            url: "events/\(eventId)/joinRequests",
            queryParams: [:],
            config: AdelsonFirebaseAuthConfig.shared
        )
    }

    func respondToRequest(eventId: String, requesterId: String, accept: Bool) async throws -> JoinRespondResponse {
        let caller = AdelsonFirebaseApiCaller<JoinRespondResponse>()
        return try await caller.call(
            url: "events/\(eventId)/joinRequests/respond",
            params: JoinRespondBody(requesterId: requesterId, accept: accept),
            method: .post,
            config: AdelsonFirebaseAuthConfig.shared
        )
    }

    func getMyStatus(eventId: String) async throws -> MyStatusResponse {
        let caller = AdelsonFirebaseApiCaller<MyStatusResponse>()
        return try await caller.callGet(
            url: "events/\(eventId)/myStatus",
            queryParams: [:],
            config: AdelsonFirebaseAuthConfig.shared
        )
    }
}

private nonisolated struct EmptyBody: Encodable, Sendable {}
