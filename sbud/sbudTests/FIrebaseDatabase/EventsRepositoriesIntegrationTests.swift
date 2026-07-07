//
//  EventsRepositoriesIntegrationTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 07/07/2026.
//


import XCTest
import FirebaseCore
import FirebaseFirestore
@testable import sbud

// il Firebase Emulator (deve essere avviato!)
final class EventsRepositoriesIntegrationTests: XCTestCase {

    let db = Firestore.firestore()

    override func setUp() async throws {
        try await super.setUp()
        try await clearEmulatorFirestore()
    }

    private func clearEmulatorFirestore() async throws {
        guard let projectId = FirebaseApp.app()?.options.projectID else { return }
        let url = URL(string: "http://localhost:8080/emulator/v1/projects/\(projectId)/databases/(default)/documents")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        _ = try await URLSession.shared.data(for: request)
    }

    // MARK: - Helpers

    private func makeJoinedEvent(title: String = "Corsa al parco",
                                 eventId: String = "ev_1",
                                 userId: String = "user_1",
                                 status: UsersEventStatus = .proposed) -> JoinedEvent {
        var event = JoinedEvent()
        event.title = title
        event.eventId = eventId
        event.userId = userId
        event.status = status
        event.activityType = .running
        event.userFirstName = "Mario"
        event.userLastName = "Rossi"
        return event
    }

    // MARK: - JoinedEventsRepository: CRUD

    func test_create_returnsIdAndPersistsEvent() async throws {
        let sut = JoinedEventsRepository()
        let event = makeJoinedEvent(title: "Nuotata")

        let id = try await sut.create(event)

        XCTAssertFalse(id.isEmpty)
        let fetched = try await sut.fetchById(id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.title, "Nuotata")
        XCTAssertEqual(fetched?.userFirstName, "Mario")
    }

    func test_fetchById_nonExistentId_returnsNil() async throws {
        let sut = JoinedEventsRepository()

        let result = try await sut.fetchById("non_esiste_proprio")

        XCTAssertNil(result)
    }

    func test_update_mergesNewData() async throws {
        let sut = JoinedEventsRepository()
        let id = try await sut.create(makeJoinedEvent(title: "Titolo vecchio"))

        var updated = makeJoinedEvent(title: "Titolo nuovo")
        updated.status = .confirmed
        try await sut.update(id, updated)

        let fetched = try await sut.fetchById(id)
        XCTAssertEqual(fetched?.title, "Titolo nuovo")
        XCTAssertEqual(fetched?.status, .confirmed)
    }

    func test_delete_removesEvent() async throws {
        let sut = JoinedEventsRepository()
        let id = try await sut.create(makeJoinedEvent())

        try await sut.delete(id)

        let fetched = try await sut.fetchById(id)
        XCTAssertNil(fetched)
    }

    // MARK: - JoinedEventsRepository: fetch con query

    func test_fetch_filtersByUserId() async throws {
        let sut = JoinedEventsRepository()
        try await sut.create(makeJoinedEvent(eventId: "ev_1", userId: "alice"))
        try await sut.create(makeJoinedEvent(eventId: "ev_2", userId: "alice"))
        try await sut.create(makeJoinedEvent(eventId: "ev_3", userId: "bob"))

        var builder = sut.initQueryBuilderObject()
        builder = builder.appendFilter(
            Filter(field: sut.constants.userId, operation: .isEqualTo, value: "alice")
        )
        let results = try await sut.fetch(query: builder)

        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.userId == "alice" })
    }

    func test_fetch_emptyCollection_returnsEmpty() async throws {
        let sut = JoinedEventsRepository()

        let results = try await sut.fetch(query: sut.initQueryBuilderObject())

        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - JoinedEvent: conversione

    func test_toUserEvent_copiesAllRelevantFields() {
        let joined = makeJoinedEvent(title: "Sciata", eventId: "ev_42", status: .confirmed)

        let userEvent = joined.toUserEvent()

        XCTAssertEqual(userEvent.title, "Sciata")
        XCTAssertEqual(userEvent.eventId, "ev_42")
        XCTAssertEqual(userEvent.status, .confirmed)
        XCTAssertEqual(userEvent.activityType, .running)
    }

    // MARK: - UsersEventRepository: fetch (unico metodo implementato)

    func test_usersEventRepository_fetch_mapsDocumentsCorrectly() async throws {
        // Seminiamo direttamente un documento nel formato che fetch() si aspetta
        try await db.collection("Events").document("event_test_1").setData([
            "activityType": "Tennis",
            "title": "Partita al circolo",
            "eventImage": "http://img.test/1.jpg",
            "status": "proposed",
            "isPublic": true
        ])

        let sut = UsersEventRepository()
        let results = try await sut.fetch(query: sut.initQueryBuilderObject())

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Partita al circolo")
        XCTAssertEqual(results.first?.activityType, .tennis)
        XCTAssertEqual(results.first?.eventId, "event_test_1")
    }

    func test_usersEventRepository_fetch_skipsMalformedDocuments() async throws {
        // Documento senza i campi obbligatori: deve essere scartato, non crashare
        try await db.collection("Events").document("rotto").setData([
            "title": "Senza gli altri campi"
        ])
        try await db.collection("Events").document("valido").setData([
            "activityType": "Gym",
            "title": "Allenamento",
            "eventImage": "",
            "status": "confirmed"
        ])

        let sut = UsersEventRepository()
        let results = try await sut.fetch(query: sut.initQueryBuilderObject())

        XCTAssertEqual(results.count, 1, "Il documento malformato va scartato silenziosamente")
        XCTAssertEqual(results.first?.title, "Allenamento")
    }

    func test_usersEventRepository_fetch_missingIsPublic_defaultsToTrue() async throws {
        try await db.collection("Events").document("senza_flag").setData([
            "activityType": "Running",
            "title": "Evento senza isPublic",
            "eventImage": "",
            "status": "proposed"
        ])

        let sut = UsersEventRepository()
        let results = try await sut.fetch(query: sut.initQueryBuilderObject())

        XCTAssertEqual(results.first?.isPublic, true)
    }
}
