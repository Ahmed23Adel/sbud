//
//  HomeCoordinatorTests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest
@testable import sbud

@MainActor
final class HomeCoordinatorTests: XCTestCase {

    private var sut: HomeCoordinator!

    override func setUp() {
        super.setUp()
        sut = HomeCoordinator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_init_navigationPathIsEmpty() {
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    func test_init_activeSheetIsNil() {
        XCTAssertNil(sut.activeSheet)
    }

    func test_init_authDelegateIsNil() {
        XCTAssertNil(sut.authDelegate)
    }

    // MARK: - Push Navigation

    func test_goToMyEventDetail_appendsCorrectDestination() {
        sut.goToMyEventDetail(eventId: "event1")
        XCTAssertEqual(sut.navigationPath.count, 1)
        XCTAssertEqual(sut.navigationPath.last, .myEventDetail(eventId: "event1"))
    }

    func test_goToOthersEventDetail_appendsCorrectDestination() {
        sut.goToOthersEventDetail(eventId: "event2")
        XCTAssertEqual(sut.navigationPath.last, .othersEventDetail(eventId: "event2"))
    }

    func test_goToProfile_appendsCorrectDestination() {
        sut.goToProfile(userId: "user1")
        XCTAssertEqual(sut.navigationPath.last, .profileView(userId: "user1"))
    }

    func test_goToFriendsList_appendsCorrectDestination() {
        sut.goToFriendsList(userId: "user1")
        XCTAssertEqual(sut.navigationPath.last, .friendsList(userId: "user1"))
    }

    func test_goToMyEvents_appendsCorrectDestination() {
        sut.goToMyEvents(userId: "user1")
        XCTAssertEqual(sut.navigationPath.last, .myEvents(userId: "user1"))
    }

    func test_goToOthersEvents_appendsCorrectDestination() {
        sut.goToOthersEvents(userId: "user1")
        XCTAssertEqual(sut.navigationPath.last, .othersEvents(userId: "user1"))
    }

    func test_goToChat_appendsCorrectDestination() {
        let user = UserProfile.fixture(id: "user42")
        sut.goToChat(user: user, eventId: "evt1", eventTitle: "Morning Run")
        XCTAssertEqual(sut.navigationPath.count, 1)

        guard case .chat(let pushedUser, let eventId, let eventTitle) = sut.navigationPath.last else {
            return XCTFail("Expected .chat destination")
        }
        XCTAssertEqual(pushedUser.id, "user42")
        XCTAssertEqual(eventId, "evt1")
        XCTAssertEqual(eventTitle, "Morning Run")
    }

    func test_multiplePushes_accumulateInCallOrder() {
        sut.goToMyEventDetail(eventId: "e1")
        sut.goToProfile(userId: "u1")
        sut.goToFriendsList(userId: "u1")

        XCTAssertEqual(sut.navigationPath, [
            .myEventDetail(eventId: "e1"),
            .profileView(userId: "u1"),
            .friendsList(userId: "u1")
        ])
    }

    // MARK: - Pop Navigation

    func test_pop_whenPathHasOneItem_pathBecomesEmpty() {
        sut.goToMyEventDetail(eventId: "e1")
        sut.pop()
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    func test_pop_whenPathHasMultipleItems_removesOnlyLast() {
        sut.goToMyEventDetail(eventId: "e1")
        sut.goToProfile(userId: "u1")
        sut.pop()
        XCTAssertEqual(sut.navigationPath, [.myEventDetail(eventId: "e1")])
    }

    func test_pop_whenPathIsEmpty_doesNotCrash() {
        XCTAssertTrue(sut.navigationPath.isEmpty)
        sut.pop()
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    func test_popToRoot_clearsAllItems() {
        sut.goToMyEventDetail(eventId: "e1")
        sut.goToOthersEventDetail(eventId: "e2")
        sut.goToProfile(userId: "u1")
        sut.popToRoot()
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    func test_popToRoot_onEmptyPath_remainsEmpty() {
        sut.popToRoot()
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    // MARK: - Sheet Presentation

    func test_dismissSheet_whenSheetIsNil_remainsNil() {
        sut.dismissSheet()
        XCTAssertNil(sut.activeSheet)
    }

    // MARK: - Memory Safety

    func test_coordinator_noMemoryLeak() {
        var coord: HomeCoordinator? = HomeCoordinator()
        weak var weakCoord = coord
        addTeardownBlock { XCTAssertNil(weakCoord, "HomeCoordinator leaked") }
        coord = nil
    }
}

// MARK: - HomeDestination

final class HomeDestinationTests: XCTestCase {

    func test_equality_sameCaseSameId_isEqual() {
        XCTAssertEqual(HomeDestination.myEventDetail(eventId: "e1"), .myEventDetail(eventId: "e1"))
    }

    func test_equality_sameCaseDifferentId_isNotEqual() {
        XCTAssertNotEqual(HomeDestination.myEventDetail(eventId: "e1"), .myEventDetail(eventId: "e2"))
    }

    func test_equality_differentCases_isNotEqual() {
        XCTAssertNotEqual(HomeDestination.myEventDetail(eventId: "e1"), .othersEventDetail(eventId: "e1"))
    }

    func test_equality_myEventDetailVsMyEventDetails_areDistinctCases() {
        // .myEventDetail and .myEventDetails are intentionally separate cases even though
        // HomeAppCoordinator pattern-matches both to the same view — confirms the enum
        // itself does not unify them, so that routing logic stays the single source of truth.
        XCTAssertNotEqual(HomeDestination.myEventDetail(eventId: "e1"), .myEventDetails(eventId: "e1"))
    }

    func test_equality_othersEventDetailVsOthersEventDetails_areDistinctCases() {
        XCTAssertNotEqual(HomeDestination.othersEventDetail(eventId: "e1"), .othersEventDetails(eventId: "e1"))
    }

    func test_equality_chat_comparesUserIdEventIdAndTitle() {
        let user = UserProfile.fixture(id: "u1")
        let a = HomeDestination.chat(user: user, eventId: "e1", eventTitle: "Run")
        let b = HomeDestination.chat(user: user, eventId: "e1", eventTitle: "Run")
        XCTAssertEqual(a, b)
    }

    func test_equality_chat_differentEventId_isNotEqual() {
        let user = UserProfile.fixture(id: "u1")
        let a = HomeDestination.chat(user: user, eventId: "e1", eventTitle: "Run")
        let b = HomeDestination.chat(user: user, eventId: "e2", eventTitle: "Run")
        XCTAssertNotEqual(a, b)
    }

    func test_equality_chat_differentUser_isNotEqual() {
        let a = HomeDestination.chat(user: .fixture(id: "u1"), eventId: "e1", eventTitle: "Run")
        let b = HomeDestination.chat(user: .fixture(id: "u2"), eventId: "e1", eventTitle: "Run")
        XCTAssertNotEqual(a, b)
    }

    func test_hash_equalValues_produceEqualHashes() {
        let a = HomeDestination.profileView(userId: "u1")
        let b = HomeDestination.profileView(userId: "u1")
        XCTAssertEqual(a.hashValue, b.hashValue)
    }

    func test_usableAsSetElement_deduplicatesEqualDestinations() {
        let set: Set<HomeDestination> = [
            .myEvents(userId: "u1"),
            .myEvents(userId: "u1"),
            .othersEvents(userId: "u1")
        ]
        XCTAssertEqual(set.count, 2)
    }
}

// MARK: - UserProfile fixture

extension UserProfile {
    static func fixture(
        id: String = "user-fixture-id",
        name: String = "Test User"
    ) -> UserProfile {
        var p = UserProfile(id: id)
        p.name = name
        return p
    }
}
