//
//  MessagesTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 06/07/2026.
//


import XCTest
import SwiftUI
import FirebaseFirestore
@testable import sbud

final class MessagesTests: XCTestCase {

    // MARK: - Helpers

    private func makeMessage(id: String = "msg1",
                             fromId: String = "sender",
                             toId: String = "receiver",
                             text: String = "ciao",
                             eventId: String? = "ev1",
                             isRead: Bool? = nil,
                             date: Date = Date()) -> Message {
        Message(
            id: id,
            fromId: fromId,
            toId: toId,
            timestamp: Timestamp(date: date),
            text: text,
            eventId: eventId,
            user: nil,
            isRead: isRead
        )
    }

    // MARK: - chatPartnerId

    func test_chatPartnerId_whenIAmSender_returnsReceiver() {
        let msg = makeMessage(fromId: "me", toId: "friend")
        XCTAssertEqual(msg.chatPartnerId(currentUid: "me"), "friend")
    }

    func test_chatPartnerId_whenIAmReceiver_returnsSender() {
        let msg = makeMessage(fromId: "friend", toId: "me")
        XCTAssertEqual(msg.chatPartnerId(currentUid: "me"), "friend")
    }

    // MARK: - Equatable / Hashable

    func test_messages_withSameId_areEqual() {
        let a = makeMessage(id: "same", text: "testo A")
        let b = makeMessage(id: "same", text: "testo B completamente diverso")
        XCTAssertEqual(a, b, "Due messaggi con lo stesso id devono essere uguali")
    }

    func test_messages_withDifferentId_areNotEqual() {
        let a = makeMessage(id: "uno")
        let b = makeMessage(id: "due")
        XCTAssertNotEqual(a, b)
    }

    func test_messages_withSameId_haveSameHash() {
        let a = makeMessage(id: "same")
        let b = makeMessage(id: "same", text: "altro testo")
        XCTAssertEqual(a.hashValue, b.hashValue)
    }

    func test_messages_inSet_areDeduplicatedById() {
        let a = makeMessage(id: "same")
        let b = makeMessage(id: "same")
        let set: Set<Message> = [a, b]
        XCTAssertEqual(set.count, 1)
    }

    // MARK: - MessageViewModel

    func test_isFromCurrentUser_true_whenFromIdMatchesUid() {
        let msg = makeMessage(fromId: "me")
        let vm = MessageViewModel(message: msg, currentUid: "me")
        XCTAssertTrue(vm.isFromCurrentUser)
    }

    func test_isFromCurrentUser_false_whenFromIdIsSomeoneElse() {
        let msg = makeMessage(fromId: "friend")
        let vm = MessageViewModel(message: msg, currentUid: "me")
        XCTAssertFalse(vm.isFromCurrentUser)
    }

    func test_isFromCurrentUser_false_whenUidIsEmpty() {
        // Utente non loggato: nessun messaggio deve risultare "mio"
        let msg = makeMessage(fromId: "friend")
        let vm = MessageViewModel(message: msg, currentUid: "")
        XCTAssertFalse(vm.isFromCurrentUser)
    }

    // MARK: - ChatRoomId

    func test_chatRoomId_isBuiltAsPartnerIdUnderscoreEventId() {
        let result = ChatViewModel.chatRoomId(partnerId: "user_9", eventId: "event_7")
        XCTAssertEqual(result, "user_9_event_7")
    }

    func test_chatRoomIds_forSenderAndRecipient_areMirrored() {
        // Verifica la simmetria: la room del mittente usa l'id del destinatario e viceversa.
        // Se questa logica si rompe, i due utenti scrivono in chat diverse e non si vedono.
        let myUid = "me", friendUid = "friend", event = "ev1"

        let roomWhereIWrite = ChatViewModel.chatRoomId(partnerId: friendUid, eventId: event)
        let roomWhereFriendReads = ChatViewModel.chatRoomId(partnerId: myUid, eventId: event)

        XCTAssertEqual(roomWhereIWrite, "friend_ev1")
        XCTAssertEqual(roomWhereFriendReads, "me_ev1")
        XCTAssertNotEqual(roomWhereIWrite, roomWhereFriendReads)
    }

    // MARK: - ChatBubble (Shape)

    func test_chatBubble_producesNonEmptyPath() {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 60)
        XCTAssertFalse(ChatBubble(isFromCurrentUser: true).path(in: rect).isEmpty)
        XCTAssertFalse(ChatBubble(isFromCurrentUser: false).path(in: rect).isEmpty)
    }

    func test_chatBubble_pathStaysInsideBounds() {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 60)
        let bounding = ChatBubble(isFromCurrentUser: true).path(in: rect).boundingRect
        XCTAssertTrue(rect.contains(bounding) || bounding == rect)
    }

    func test_chatBubble_currentUserAndOther_produceDifferentShapes() {
        // I due lati arrotondano angoli diversi, quindi i path devono differire
        let rect = CGRect(x: 0, y: 0, width: 200, height: 60)
        let mine = ChatBubble(isFromCurrentUser: true).path(in: rect).description
        let theirs = ChatBubble(isFromCurrentUser: false).path(in: rect).description
        XCTAssertNotEqual(mine, theirs)
    }

    // MARK: - Ordinamento messaggi recenti

    func test_sortMessages_newestFirst() {
        let old = makeMessage(id: "old", date: Date(timeIntervalSince1970: 1000))
        let mid = makeMessage(id: "mid", date: Date(timeIntervalSince1970: 2000))
        let new = makeMessage(id: "new", date: Date(timeIntervalSince1970: 3000))

        var msgs = [mid, old, new]
        msgs.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }

        XCTAssertEqual(msgs.map(\.id), ["new", "mid", "old"])
    }

    // MARK: - Conteggio non letti (logica di EventUnreadBadge)

    func test_unreadCount_countsOnlyExplicitlyUnread() {
        let messages = [
            makeMessage(id: "1", isRead: false),
            makeMessage(id: "2", isRead: true),
            makeMessage(id: "3", isRead: false),
            makeMessage(id: "4", isRead: nil)  // messaggi vecchi senza campo
        ]

        let count = messages.filter { $0.isRead == false }.count

        XCTAssertEqual(count, 2, "isRead nil non deve contare come non letto")
    }
}