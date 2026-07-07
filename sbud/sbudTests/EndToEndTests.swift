//
//  EndToEndTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 07/07/2026.
//


import XCTest
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
@testable import sbud


// 
final class EndToEndTests: XCTestCase {

    let db = Firestore.firestore()
    private var savedProfile: UserProfile?

    override func setUp() async throws {
        try await super.setUp()
        try await clearEmulatorFirestore()
        savedProfile = ProfileManager.shared.getLocalProfile()
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

    @MainActor
    func test_fullUserJourney_signUp_friendship_chat() async throws {
        // ── 1. REGISTRAZIONE: Alice si crea un account
        let aliceAuth = try await Auth.auth().createUser(
            withEmail: "alice\(Int.random(in: 0..<100000))@sbud.test",
            password: "password123"
        )
        let aliceUid = aliceAuth.user.uid

        // ── 2. PROFILO: Alice completa il suo profilo
        let userRepo = UserRepository()
        var aliceProfile = UserProfile(id: aliceUid)
        aliceProfile.name = "Alice"
        aliceProfile.surName = "Verdi"
        aliceProfile.preferredActivity = .running
        let saveError = try await userRepo.save(aliceProfile)
        XCTAssertNil(saveError, "Il salvataggio del profilo non deve dare errori")

        // Bob esiste già nel sistema (seminato direttamente)
        let bobUid = "bob_e2e"
        var bobProfile = UserProfile(id: bobUid)
        bobProfile.name = "Bob"
        try db.collection("users").document(bobUid)
            .setData(from: bobProfile, merge: true)

        // ── 3. AMICIZIA: Alice manda richiesta, Bob accetta
        let friendRepo = FriendRepository()
        try await friendRepo.sendFriendRequest(fromUserId: aliceUid, toUserId: bobUid)

        var status = try await friendRepo.getFriendStatus(currentUserId: aliceUid, targetUserId: bobUid)
        XCTAssertEqual(status, .requestSent)

        try await friendRepo.acceptFriendRequest(currentUserId: bobUid, requesterId: aliceUid)

        status = try await friendRepo.getFriendStatus(currentUserId: aliceUid, targetUserId: bobUid)
        XCTAssertEqual(status, .friends, "Dopo l'accettazione devono essere amici")

        // ── 4. CHAT: Alice (loggata) scrive a Bob per un evento
        ProfileManager.shared.saveProfileToLocale(profile: aliceProfile)
        let eventId = "evento_corsa_e2e"
        let chatVM = ChatViewModel(user: bobProfile, eventId: eventId)

        chatVM.sendMessage("Ciao Bob! Ci vediamo alla corsa?")
        try await Task.sleep(nanoseconds: 2_000_000_000)

        // ── 5. VERIFICA LATO BOB: il messaggio è arrivato, non letto
        let bobRoom = ChatViewModel.chatRoomId(partnerId: aliceUid, eventId: eventId)
        let bobMessages = try await db.collection("messages").document(bobUid)
            .collection(bobRoom).getDocuments()
        XCTAssertEqual(bobMessages.documents.count, 1)
        XCTAssertEqual(bobMessages.documents.first?.data()["text"] as? String,
                       "Ciao Bob! Ci vediamo alla corsa?")
        XCTAssertEqual(bobMessages.documents.first?.data()["isRead"] as? Bool, false,
                       "Per Bob il messaggio deve risultare non letto")

        // ── 6. IL LISTENER DI ALICE riceve il proprio messaggio in tempo reale
        for _ in 0..<50 {
            if !chatVM.messages.isEmpty { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        XCTAssertEqual(chatVM.messages.count, 1)

        // ── 7. FINE FLUSSO: Alice rimuove l'amicizia
        try await friendRepo.removeFriend(currentUserId: aliceUid, targetUserId: bobUid)
        status = try await friendRepo.getFriendStatus(currentUserId: aliceUid, targetUserId: bobUid)
        XCTAssertEqual(status, .notFriend)
    }
}
