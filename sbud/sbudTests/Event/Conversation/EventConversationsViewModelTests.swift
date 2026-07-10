//
//  EventConversationsViewModelTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 10/07/2026.
//


import XCTest
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
@testable import sbud

@MainActor
final class EventConversationsViewModelTests: XCTestCase {

    var myUid: String!
    let partnerId = "conv_partner_1"
    let eventId = "conv_event_1"

    override func setUp() async throws {
        try await super.setUp()
        try await clearEmulatorFirestore()
        let email = "conv\(Int.random(in: 0..<100000))@sbud.test"
        let result = try await Auth.auth().createUser(withEmail: email, password: "password123")
        myUid = result.user.uid
    }

    override func tearDown() async throws {
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

    /// Semina una recent-message per l'utente corrente su un certo evento
    private func seedRecentMessage(eventId: String, text: String,
                                   date: Date = Date()) async throws {
        let room = "\(partnerId)_\(eventId)"
        try await Firestore.firestore()
            .collection("messages").document(myUid)
            .collection("recent-messages").document(room)
            .setData([
                "text": text,
                "id": UUID().uuidString,
                "fromId": partnerId,
                "toId": myUid,
                "eventId": eventId,
                "timestamp": Timestamp(date: date),
                "isRead": false
            ])
    }

    private func waitForMessages(_ sut: EventConversationsViewModel, count: Int) async {
        for _ in 0..<80 {
            if sut.recentMessages.count == count { return }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    // MARK: - Tests

    func test_init_setsEventId_andEmptyMessages() {
        let sut = EventConversationsViewModel(eventId: eventId)
        XCTAssertEqual(sut.eventId, eventId)
        XCTAssertTrue(sut.recentMessages.isEmpty)
    }

    func test_loadData_receivesSeededMessage() async throws {
        try await seedRecentMessage(eventId: eventId, text: "Ciao!")
        let sut = EventConversationsViewModel(eventId: eventId)

        sut.loadData()
        await waitForMessages(sut, count: 1)

        XCTAssertEqual(sut.recentMessages.count, 1)
        XCTAssertEqual(sut.recentMessages.first?.text, "Ciao!")
    }

    func test_loadData_filtersByEventId() async throws {
        try await seedRecentMessage(eventId: eventId, text: "Del mio evento")
        try await seedRecentMessage(eventId: "altro_evento", text: "Di un altro evento")
        let sut = EventConversationsViewModel(eventId: eventId)

        sut.loadData()
        await waitForMessages(sut, count: 1)

        XCTAssertEqual(sut.recentMessages.count, 1)
        XCTAssertEqual(sut.recentMessages.first?.text, "Del mio evento")
    }

    func test_loadData_sortsNewestFirst() async throws {
        // Due chat diverse (partner diversi) sullo stesso evento
        let room2Partner = "conv_partner_2"
        try await seedRecentMessage(eventId: eventId, text: "vecchio",
                                    date: Date(timeIntervalSince1970: 1_000))
        try await Firestore.firestore()
            .collection("messages").document(myUid)
            .collection("recent-messages").document("\(room2Partner)_\(eventId)")
            .setData([
                "text": "nuovo", "id": UUID().uuidString,
                "fromId": room2Partner, "toId": myUid!,
                "eventId": eventId,
                "timestamp": Timestamp(date: Date(timeIntervalSince1970: 2_000)),
                "isRead": false
            ])
        let sut = EventConversationsViewModel(eventId: eventId)

        sut.loadData()
        await waitForMessages(sut, count: 2)

        XCTAssertEqual(sut.recentMessages.map(\.text), ["nuovo", "vecchio"])
    }

    func test_loadData_attachesPartnerProfile_whenExists() async throws {
        var profile = UserProfile(id: partnerId)
        profile.name = "Carla"
        try Firestore.firestore().collection("users").document(partnerId)
            .setData(from: profile, merge: true)
        try await seedRecentMessage(eventId: eventId, text: "con profilo")
        let sut = EventConversationsViewModel(eventId: eventId)

        sut.loadData()
        await waitForMessages(sut, count: 1)
        // Il fetch dei profili è un Task successivo: attesa extra
        for _ in 0..<50 {
            if sut.recentMessages.first?.user != nil { break }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }

        XCTAssertEqual(sut.recentMessages.first?.user?.name, "Carla")
    }

    func test_loadData_listenerUpdatesInRealTime() async throws {
        let sut = EventConversationsViewModel(eventId: eventId)
        sut.loadData()
        try await Task.sleep(nanoseconds: 1_000_000_000) // listener attivo, lista vuota
        XCTAssertTrue(sut.recentMessages.isEmpty)

        // Arriva un messaggio DOPO l'attivazione del listener
        try await seedRecentMessage(eventId: eventId, text: "in tempo reale")
        await waitForMessages(sut, count: 1)

        XCTAssertEqual(sut.recentMessages.first?.text, "in tempo reale")
    }
}
