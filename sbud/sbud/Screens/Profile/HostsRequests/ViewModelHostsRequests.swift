//
//  ViewModelHostsRequests.swift
//  sbud
//
//  Created by ahmed on 03/05/2026.
//
import Foundation
import FirebaseFirestore
import FirebaseAnalytics
internal import Alamofire
import AdelsonAuthManager
import AdelsonApiCaller

struct HostInvitationItem: Identifiable {
    let id: String
    let title: String
    let imageUrl: String?
    let invitedAt: Date
}

nonisolated struct HostInvitationResponse: Decodable, Sendable { let status: String; let message: String }
nonisolated struct HostInvitationBody: Encodable, Sendable { let accept: Bool }

// MARK: - Protocols

protocol HostInvitationFetching {
    func fetchInvitations(userId: String) async throws -> [HostInvitationItem]
}

protocol HostInvitationResponding {
    func respond(eventId: String, accept: Bool) async throws
}

// MARK: - Real implementations

final class FirestoreHostInvitationFetcher: HostInvitationFetching {
    private let db = Firestore.firestore()
    private let friendManager: FriendManager
    init(friendManager: FriendManager = .shared) { self.friendManager = friendManager }

    func fetchInvitations(userId: String) async throws -> [HostInvitationItem] {
        let eventIds = try await friendManager.fetchHostsPendingRequests(userId: userId)
        var items: [HostInvitationItem] = []
        for eventId in eventIds {
            async let eventDoc  = db.collection("Events").document(eventId).getDocument()
            async let inviteDoc = db.collection("users").document(userId).collection("hostInvitations").document(eventId).getDocument()
            let (event, invite) = try await (eventDoc, inviteDoc)
            items.append(HostInvitationItem(
                id: eventId,
                title: event.data()?["title"] as? String ?? "Untitled Event",
                imageUrl: event.data()?["eventImage"] as? String,
                invitedAt: (invite.data()?["invitedAt"] as? Timestamp)?.dateValue() ?? Date()
            ))
        }
        return items
    }
}

final class AdelsonHostInvitationResponder: HostInvitationResponding {
    func respond(eventId: String, accept: Bool) async throws {
        let caller = AdelsonFirebaseApiCaller<HostInvitationResponse>()
        _ = try await caller.call(url: "events/\(eventId)/hosts/respond",
                                   params: HostInvitationBody(accept: accept),
                                   method: .post, config: AdelsonFirebaseAuthConfig.shared)
    }
}

// MARK: - ViewModel

@MainActor
@Observable
class ViewModelHostsRequests {
    var invitations: [HostInvitationItem] = []
    var isLoading = false
    var errorMessage: String?

    private let fetcher: HostInvitationFetching
    private let responder: HostInvitationResponding
    private let currentUserProvider: CurrentUserProviding

    init(
        fetcher: HostInvitationFetching? = nil,
        responder: HostInvitationResponding = AdelsonHostInvitationResponder(),
        currentUserProvider: CurrentUserProviding = FirebaseCurrentUserProvider()
    ) {
        self.fetcher = fetcher ?? FirestoreHostInvitationFetcher()
        self.responder = responder
        self.currentUserProvider = currentUserProvider
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "HostsRequests"])
    }

    func load() async {
        guard let uid = currentUserProvider.currentUserId else { return }
        isLoading = true
        defer { isLoading = false }
        do { invitations = try await fetcher.fetchInvitations(userId: uid) } catch { errorMessage = error.localizedDescription }
    }

    func accept(eventId: String) async { await respond(eventId: eventId, accept: true) }
    func decline(eventId: String) async { await respond(eventId: eventId, accept: false) }

    private func respond(eventId: String, accept: Bool) async {
        do {
            try await responder.respond(eventId: eventId, accept: accept)
            invitations.removeAll { $0.id == eventId }
        } catch { errorMessage = error.localizedDescription }
    }
}
