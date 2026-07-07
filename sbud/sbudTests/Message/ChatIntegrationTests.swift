//
//  ChatIntegrationTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 07/07/2026.
//


import XCTest
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
@testable import sbud


@MainActor
final class ChatIntegrationTests: XCTestCase {

    var myUid: String!
    let partnerId = "partner_user_1"
    let eventId = "event_integration_1"

    override func setUp() async throws {
        try await super.setUp()

        try await clearEmulatorFirestore()

        let email = "test\(Int.random(in: 0..<100000))@sbud.test"
        let result = try await Auth.auth().createUser(withEmail: email, password: "password123")
        myUid = result.user.uid
    }

    private func clearEmulatorFirestore() async throws {
        guard let projectId = FirebaseApp.app()?.options.projectID else { return }
        let url = URL(string: "http://localhost:8080/emulator/v1/projects/\(projectId)/databases/(default)/documents")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try await URLSession.shared.data(for: request)
    }

    override func tearDown() async throws {
        try? Auth.auth().signOut()
        try await super.tearDown()
    }

    func test_sendMessage_writesMessageForBothUsers() async throws {
        var partner = UserProfile(id: partnerId)
        let vm = ChatViewModel(user: partner, eventId: eventId)

        vm.sendMessage("Ciao dall'integration test!")

        // Le scritture sono asincrone: diamo tempo all'emulatore
        try await Task.sleep(nanoseconds: 2_000_000_000)

        // Verifica lato mittente
        let myRoom = ChatViewModel.chatRoomId(partnerId: partnerId, eventId: eventId)
        let mySnapshot = try await Firestore.firestore()
            .collection("messages").document(myUid)
            .collection(myRoom).getDocuments()
        XCTAssertEqual(mySnapshot.documents.count, 1)
        XCTAssertEqual(mySnapshot.documents.first?.data()["text"] as? String,
                       "Ciao dall'integration test!")
        XCTAssertEqual(mySnapshot.documents.first?.data()["isRead"] as? Bool, true)

        // Verifica lato destinatario (isRead deve essere false!)
        let partnerRoom = ChatViewModel.chatRoomId(partnerId: myUid, eventId: eventId)
        let partnerSnapshot = try await Firestore.firestore()
            .collection("messages").document(partnerId)
            .collection(partnerRoom).getDocuments()
        XCTAssertEqual(partnerSnapshot.documents.count, 1)
        XCTAssertEqual(partnerSnapshot.documents.first?.data()["isRead"] as? Bool, false)
    }

    func test_sendMessage_updatesRecentMessagesForBothUsers() async throws {
        let vm = ChatViewModel(user: UserProfile(id: partnerId), eventId: eventId)

        vm.sendMessage("Recent check")
        try await Task.sleep(nanoseconds: 2_000_000_000)

        let myRecent = try await Firestore.firestore()
            .collection("messages").document(myUid)
            .collection("recent-messages").getDocuments()
        XCTAssertEqual(myRecent.documents.count, 1)

        let partnerRecent = try await Firestore.firestore()
            .collection("messages").document(partnerId)
            .collection("recent-messages").getDocuments()
        XCTAssertEqual(partnerRecent.documents.count, 1)
        XCTAssertEqual(partnerRecent.documents.first?.data()["eventId"] as? String, eventId)
    }

    func test_fetchMessages_receivesSentMessage() async throws {
        let vm = ChatViewModel(user: UserProfile(id: partnerId), eventId: eventId)
        // fetchMessages parte nell'init e ascolta in tempo reale

        vm.sendMessage("Mi vedi?")

        // Aspettiamo che il listener riceva il messaggio
        for _ in 0..<50 {
            if !vm.messages.isEmpty { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }

        XCTAssertEqual(vm.messages.count, 1)
        XCTAssertEqual(vm.messages.first?.text, "Mi vedi?")
    }

    func test_markMessagesAsRead_setsIsReadTrue() async throws {
        let vm = ChatViewModel(user: UserProfile(id: partnerId), eventId: eventId)
        vm.sendMessage("msg")
        try await Task.sleep(nanoseconds: 2_000_000_000)

        vm.markMessagesAsRead()
        try await Task.sleep(nanoseconds: 1_000_000_000)

        let room = ChatViewModel.chatRoomId(partnerId: partnerId, eventId: eventId)
        let doc = try await Firestore.firestore()
            .collection("messages").document(myUid)
            .collection("recent-messages").document(room).getDocument()
        XCTAssertEqual(doc.data()?["isRead"] as? Bool, true)
    }
}
