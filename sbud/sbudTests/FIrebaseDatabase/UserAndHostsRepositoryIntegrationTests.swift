//
//  UserAndHostsRepositoryIntegrationTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 07/07/2026.
//


import XCTest
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
@testable import sbud

// su Firebase Emulator
final class UserAndHostsRepositoryIntegrationTests: XCTestCase {

    let db = Firestore.firestore()
    var myUid: String!
    private var savedProfile: UserProfile?

    override func setUp() async throws {
        try await super.setUp()
        try await clearEmulatorFirestore()

        // Utente loggato sull'emulatore (serve a UserRepository.save)
        let email = "test\(Int.random(in: 0..<100000))@sbud.test"
        let result = try await Auth.auth().createUser(withEmail: email, password: "password123")
        myUid = result.user.uid

        // Profilo locale (serve a HostsRepository.init)
        savedProfile = ProfileManager.shared.getLocalProfile()
        ProfileManager.shared.saveProfileToLocale(profile: UserProfile(id: myUid))
    }

    override func tearDown() async throws {
        if let savedProfile {
            ProfileManager.shared.saveProfileToLocale(profile: savedProfile)
        } else {
            ProfileManager.shared.deleteProfileFromLocale()
        }
        try? Auth.auth().signOut()
        try await super.tearDown()
    }

    private func clearEmulatorFirestore() async throws {
        guard let projectId = FirebaseApp.app()?.options.projectID else { return }
        let url = URL(string: "http://localhost:8080/emulator/v1/projects/\(projectId)/databases/(default)/documents")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try await URLSession.shared.data(for: request)
    }

    // MARK: - UserRepository

    func test_save_persistsProfile_andFetchProfileReadsItBack() async throws {
        let sut = UserRepository()
        var profile = UserProfile(id: myUid)
        profile.name = "Riccardo"
        profile.surName = "Test"
        profile.city = "Varese"
        profile.preferredActivity = .tennis

        let errorMessage = try await sut.save(profile)
        XCTAssertNil(errorMessage, "save deve ritornare nil se va tutto bene")

        let fetched = try await sut.fetchProfile(myUid)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.name, "Riccardo")
        XCTAssertEqual(fetched?.city, "Varese")
        XCTAssertEqual(fetched?.preferredActivity, .tennis)
    }

    func test_fetchProfile_nonExistentUser_returnsNil() async throws {
        let sut = UserRepository()

        let fetched = try await sut.fetchProfile("utente_fantasma")

        XCTAssertNil(fetched)
    }

    func test_updateUserProfileFields_mergesOnlyGivenFields() async throws {
        let sut = UserRepository()
        var profile = UserProfile(id: myUid)
        profile.name = "NomeOriginale"
        profile.bio = "Bio originale"
        _ = try await sut.save(profile)

        try await sut.updateUserProfileFields(uid: myUid, fields: ["bio": "Bio aggiornata"])

        let fetched = try await sut.fetchProfile(myUid)
        XCTAssertEqual(fetched?.bio, "Bio aggiornata")
        XCTAssertEqual(fetched?.name, "NomeOriginale", "I campi non toccati devono restare invariati")
    }

    // MARK: - HostsRepository: CRUD

    private let eventId = "event_host_test"
    private let invitedUserId = "invited_friend_1"

    private func makeInvitation(status: HostInvitationStatus = .pending) -> HostInvitation {
        HostInvitation(invitedAt: Date(), status: status, userId: invitedUserId)
    }

    func test_create_writesInvitationInEventHosts() async throws {
        let sut = HostsRepository(eventId: eventId)

        let returnedId = try await sut.create(makeInvitation())

        XCTAssertEqual(returnedId, invitedUserId, "create deve ritornare lo userId invitato")
        let doc = try await db.collection("Events").document(eventId)
            .collection("hosts").document(invitedUserId).getDocument()
        XCTAssertTrue(doc.exists)
        XCTAssertEqual(doc.data()?["status"] as? String, "pending")
    }

    func test_fetch_returnsInvitations() async throws {
        let sut = HostsRepository(eventId: eventId)
        try await sut.create(makeInvitation())

        let results = try await sut.fetch(query: sut.initQueryBuilderObject())

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.userId, invitedUserId)
        XCTAssertEqual(results.first?.status, .pending)
    }

    func test_update_changesStatusAndAddsRespondedAt() async throws {
        let sut = HostsRepository(eventId: eventId)
        try await sut.create(makeInvitation())

        try await sut.update(invitedUserId, makeInvitation(status: .accepted))

        let doc = try await db.collection("Events").document(eventId)
            .collection("hosts").document(invitedUserId).getDocument()
        XCTAssertEqual(doc.data()?["status"] as? String, "accepted")
        XCTAssertNotNil(doc.data()?["respondedAt"], "update deve scrivere respondedAt")
    }

    func test_delete_removesInvitation() async throws {
        let sut = HostsRepository(eventId: eventId)
        try await sut.create(makeInvitation())

        try await sut.delete(invitedUserId)

        let doc = try await db.collection("Events").document(eventId)
            .collection("hosts").document(invitedUserId).getDocument()
        XCTAssertFalse(doc.exists)
    }

    // MARK: - HostsRepository: inviteHost / removeInvitation (batch bidirezionale)

    func test_inviteHost_writesBothSides() async throws {
        let sut = HostsRepository(eventId: eventId)

        try await sut.inviteHost(makeInvitation())

        // Lato evento
        let eventDoc = try await db.collection("Events").document(eventId)
            .collection("hosts").document(invitedUserId).getDocument()
        XCTAssertTrue(eventDoc.exists)
        // Lato utente
        let userDoc = try await db.collection("users").document(invitedUserId)
            .collection("hostInvitations").document(eventId).getDocument()
        XCTAssertTrue(userDoc.exists)
        XCTAssertEqual(userDoc.data()?["status"] as? String, "pending")
    }

    func test_removeInvitation_removesBothSidesAndJoinedEvents() async throws {
        let sut = HostsRepository(eventId: eventId)
        try await sut.inviteHost(makeInvitation())

        // Simuliamo che l'invitato avesse accettato: esiste un joinedEvent da host
        var joined = JoinedEvent()
        joined.userId = invitedUserId
        joined.eventId = eventId
        joined.participationStatus = .host
        try await JoinedEventsRepository().create(joined)

        try await sut.removeInvitation(targetUserId: invitedUserId)

        let eventDoc = try await db.collection("Events").document(eventId)
            .collection("hosts").document(invitedUserId).getDocument()
        let userDoc = try await db.collection("users").document(invitedUserId)
            .collection("hostInvitations").document(eventId).getDocument()
        XCTAssertFalse(eventDoc.exists)
        XCTAssertFalse(userDoc.exists)

        let joinedLeft = try await db.collection("joinedEvents")
            .whereField("userId", isEqualTo: invitedUserId)
            .whereField("eventId", isEqualTo: eventId)
            .getDocuments()
        XCTAssertTrue(joinedLeft.documents.isEmpty,
                      "removeInvitation deve pulire anche i joinedEvents da host")
    }
}
