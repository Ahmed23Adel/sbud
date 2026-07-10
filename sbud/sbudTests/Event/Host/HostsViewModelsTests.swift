//
//  HostsViewModelsTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 10/07/2026.
//


import XCTest
import FirebaseCore
import FirebaseFirestore
@testable import sbud

@MainActor
final class HostsViewModelsTests: XCTestCase {

    private var savedProfile: UserProfile?
    let db = Firestore.firestore()
    let myUserId = "hosts_vm_user"
    let eventId = "hosts_vm_event"

    override func setUp() async throws {
        try await super.setUp()
        try await clearEmulatorFirestore()
        savedProfile = ProfileManager.shared.getLocalProfile()
        ProfileManager.shared.saveProfileToLocale(profile: UserProfile(id: myUserId))
        // documento utente per i contatori del FriendRepository
        try await db.collection("users").document(myUserId).setData(["friendsCount": 0])
    }

    override func tearDown() async throws {
        if let savedProfile {
            ProfileManager.shared.saveProfileToLocale(profile: savedProfile)
        } else {
            ProfileManager.shared.deleteProfileFromLocale()
        }
        try await super.tearDown()
    }

    private func clearEmulatorFirestore() async throws {
        guard let projectId = FirebaseApp.app()?.options.projectID else { return }
        let url = URL(string: "http://localhost:8080/emulator/v1/projects/\(projectId)/databases/(default)/documents")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try await URLSession.shared.data(for: request)
    }

    // Crea un amico con profilo completo su Firestore emulando
    private func seedFriend(id: String, name: String) async throws {
        var profile = UserProfile(id: id)
        profile.name = name
        try db.collection("users").document(id).setData(from: profile, merge: true)
        try await FriendRepository().addFriendDirectly(fromUserId: myUserId, toUserId: id)
    }

    private func makeSUT() -> ViewModelHosts {
        ViewModelHosts(eventId: eventId, userId: myUserId)
    }

    private func waitForItems(_ sut: ViewModelHosts, count: Int) async {
        for _ in 0..<50 {
            if sut.friendHostItems.count == count { return }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    // MARK: - ViewModelHosts: load + combine

    func test_init_loadsFriendsAndCombinesWithNoInvitations() async throws {
        try await seedFriend(id: "friend1", name: "Anna")
        try await seedFriend(id: "friend2", name: "Bruno")

        let sut = makeSUT()
        await waitForItems(sut, count: 2)

        XCTAssertEqual(sut.friendHostItems.count, 2)
        XCTAssertTrue(sut.friendHostItems.allSatisfy { $0.state == .notInvited })
        XCTAssertFalse(sut.isLoading)
    }

    func test_init_combinesInvitationWithFriend() async throws {
        try await seedFriend(id: "friend1", name: "Anna")
        // friend1 ha già un invito pending sull'evento
        try await HostsRepository(eventId: eventId).create(
            HostInvitation(invitedAt: Date(), status: .pending, userId: "friend1")
        )

        let sut = makeSUT()
        await waitForItems(sut, count: 1)

        XCTAssertEqual(sut.friendHostItems.first?.state, .pending)
    }

    func test_init_noFriends_itemsEmpty() async throws {
        let sut = makeSUT()
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        XCTAssertTrue(sut.friendHostItems.isEmpty)
        XCTAssertFalse(sut.isShowAlert)
    }

    // MARK: - inviteHost / cancel / remove / reInvite

    func test_inviteHost_writesInvitation_andUpdatesLocalState() async throws {
        try await seedFriend(id: "friend1", name: "Anna")
        let sut = makeSUT()
        await waitForItems(sut, count: 1)

        await sut.inviteHost(item: sut.friendHostItems[0])

        XCTAssertEqual(sut.friendHostItems.first?.state, .pending)
        let doc = try await db.collection("Events").document(eventId)
            .collection("hosts").document("friend1").getDocument()
        XCTAssertTrue(doc.exists)
    }

    func test_cancelInvitation_removesIt_andResetsLocalState() async throws {
        try await seedFriend(id: "friend1", name: "Anna")
        let sut = makeSUT()
        await waitForItems(sut, count: 1)
        await sut.inviteHost(item: sut.friendHostItems[0])

        await sut.cancelInvitation(item: sut.friendHostItems[0])

        XCTAssertEqual(sut.friendHostItems.first?.state, .notInvited)
        let doc = try await db.collection("Events").document(eventId)
            .collection("hosts").document("friend1").getDocument()
        XCTAssertFalse(doc.exists)
    }

    func test_reInviteHost_afterRejection_backToPending() async throws {
        try await seedFriend(id: "friend1", name: "Anna")
        try await HostsRepository(eventId: eventId).create(
            HostInvitation(invitedAt: Date(), status: .rejected, userId: "friend1")
        )
        let sut = makeSUT()
        await waitForItems(sut, count: 1)
        XCTAssertEqual(sut.friendHostItems.first?.state, .rejected)

        await sut.reInviteHost(item: sut.friendHostItems[0])

        XCTAssertEqual(sut.friendHostItems.first?.state, .pending)
    }

    // MARK: - FriendHostItem.state (mapping enum)

    func test_friendHostItem_stateMapping() {
        let profile = UserProfile(id: "x")
        func item(_ status: HostInvitationStatus?) -> FriendHostItem {
            FriendHostItem(id: "x", profile: profile,
                           invitation: status.map { HostInvitation(invitedAt: Date(), status: $0, userId: "x") })
        }
        XCTAssertEqual(item(nil).state, .notInvited)
        XCTAssertEqual(item(.pending).state, .pending)
        XCTAssertEqual(item(.accepted).state, .host)
        XCTAssertEqual(item(.rejected).state, .rejected)
        XCTAssertEqual(item(.notInvited).state, .notInvited)
    }
}
