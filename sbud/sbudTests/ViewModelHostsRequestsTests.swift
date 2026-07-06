//
//  ViewModelHostsRequestsTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

@MainActor
final class ViewModelHostsRequestsTests: XCTestCase {

    private var mockFetcher: MockHostInvitationFetching!
    private var mockResponder: MockHostInvitationResponding!
    private var mockProvider: MockCurrentUserProvider!
    private var sut: ViewModelHostsRequests!

    override func setUp() {
        super.setUp()
        mockFetcher = MockHostInvitationFetching()
        mockResponder = MockHostInvitationResponding()
        mockProvider = MockCurrentUserProvider()
        mockProvider.currentUserId = "me"
        sut = ViewModelHostsRequests(fetcher: mockFetcher, responder: mockResponder,
                                      currentUserProvider: mockProvider)
    }

    override func tearDown() {
        sut = nil; mockProvider = nil; mockResponder = nil; mockFetcher = nil
        super.tearDown()
    }

    func test_init_invitationsStartEmpty() {
        XCTAssertTrue(sut.invitations.isEmpty)
    }

    func test_load_populatesInvitations() async {
        mockFetcher.stubbedResult = .success([makeItem("evt1")])
        await sut.load()
        XCTAssertEqual(sut.invitations.map(\.id), ["evt1"])
    }

    func test_load_passesCurrentUserId() async {
        await sut.load()
        XCTAssertEqual(mockFetcher.lastUserId, "me")
    }

    func test_load_whenNotAuthenticated_doesNotFetch() async {
        mockProvider.currentUserId = nil
        await sut.load()
        XCTAssertNil(mockFetcher.lastUserId)
    }

    func test_load_onError_setsErrorMessage() async {
        mockFetcher.stubbedResult = .failure(URLError(.notConnectedToInternet))
        await sut.load()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_load_setsIsLoadingFalse() async {
        await sut.load()
        XCTAssertFalse(sut.isLoading)
    }

    func test_accept_removesItemAndCallsResponder() async {
        sut.invitations = [makeItem("evt1"), makeItem("evt2")]
        await sut.accept(eventId: "evt1")
        XCTAssertEqual(sut.invitations.map(\.id), ["evt2"])
        let accept = mockResponder.calls.first?.accept ?? false
        XCTAssertTrue(accept)
    }

    func test_decline_removesItemAndCallsResponder() async {
        sut.invitations = [makeItem("evt1")]
        await sut.decline(eventId: "evt1")
        XCTAssertTrue(sut.invitations.isEmpty)
        let accept = mockResponder.calls.first?.accept ?? true
        XCTAssertFalse(accept)
    }

    func test_accept_onFailure_keepsItemAndSetsError() async {
        sut.invitations = [makeItem("evt1")]
        mockResponder.stubbedResult = .failure(URLError(.notConnectedToInternet))
        await sut.accept(eventId: "evt1")
        XCTAssertEqual(sut.invitations.count, 1)
        XCTAssertNotNil(sut.errorMessage)
    }

    private func makeItem(_ id: String) -> HostInvitationItem {
        HostInvitationItem(id: id, title: "Event \(id)", imageUrl: nil, invitedAt: Date())
    }
}

