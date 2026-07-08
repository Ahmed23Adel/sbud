//
//  ProfileCoordinatorTests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest
@testable import sbud

@MainActor
final class ProfileCoordinatorTests: XCTestCase {

    // MARK: - Init / Root Route Resolution

    func test_init_sameUserIdAsCurrentUser_resolvesToMyProfile() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "u1")
        XCTAssertEqual(sut.rootRoute, .myProfile)
    }

    func test_init_differentUserIdFromCurrentUser_resolvesToOthersProfile() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "u2")
        XCTAssertEqual(sut.rootRoute, .othersProfile)
    }

    func test_init_setsUserId() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "u2")
        XCTAssertEqual(sut.userId, "u1")
    }

    func test_init_navigationPathIsEmpty() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "u1")
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    func test_init_activeSheetIsNil() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "u1")
        XCTAssertNil(sut.activeSheet)
    }

    func test_init_onPushIsNil() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "u1")
        XCTAssertNil(sut.onPush)
    }

    func test_init_delegateIsNil() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "u1")
        XCTAssertNil(sut.delegate)
    }

    // MARK: - isViewingOwnProfile

    func test_isViewingOwnProfile_whenIdsMatch_isTrue() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "u1")
        XCTAssertTrue(sut.isViewingOwnProfile)
    }

    func test_isViewingOwnProfile_whenIdsDiffer_isFalse() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "u2")
        XCTAssertFalse(sut.isViewingOwnProfile)
    }

    // MARK: - Push: Root Mode (no onPush) Appends to navigationPath

    func test_rootMode_goToOthersEvents_appendsToNavigationPath() {
        let sut = makeMyProfileCoordinator()
        sut.goToOthersEvents()
        XCTAssertEqual(sut.navigationPath, [.othersEvents(userId: "me")])
    }

    func test_rootMode_goToMyEvents_appendsToNavigationPath() {
        let sut = makeMyProfileCoordinator()
        sut.goToMyEvents()
        XCTAssertEqual(sut.navigationPath, [.myEvents(userId: "me")])
    }

    func test_rootMode_goToFriendsList_appendsToNavigationPath() {
        let sut = makeMyProfileCoordinator()
        sut.goToFriendsList()
        XCTAssertEqual(sut.navigationPath, [.friendsList(userId: "me")])
    }

    func test_rootMode_goToAppropriateEvents_ownProfile_pushesMyEvents() {
        let sut = makeMyProfileCoordinator()
        sut.goToAppropriateEvents()
        XCTAssertEqual(sut.navigationPath, [.myEvents(userId: "me")])
    }

    func test_rootMode_goToAppropriateEvents_othersProfile_pushesOthersEvents() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "me")
        sut.goToAppropriateEvents()
        XCTAssertEqual(sut.navigationPath, [.othersEvents(userId: "u1")])
    }

    func test_rootMode_goToMyEventDetails_appendsToNavigationPath() {
        let sut = makeMyProfileCoordinator()
        sut.goToMyEventDetails(eventId: "evt1")
        XCTAssertEqual(sut.navigationPath, [.myEventDetails(eventId: "evt1")])
    }

    func test_rootMode_goToOthersEventDetails_appendsToNavigationPath() {
        let sut = makeMyProfileCoordinator()
        sut.goToOthersEventDetails(eventId: "evt2")
        XCTAssertEqual(sut.navigationPath, [.othersEventDetails(eventId: "evt2")])
    }

    func test_rootMode_goToOthersProfile_appendsToNavigationPath() {
        let sut = makeMyProfileCoordinator()
        sut.goToOthersProfile(userId: "u2")
        XCTAssertEqual(sut.navigationPath, [.othersProfile(userId: "u2")])
    }

    func test_rootMode_goToEventConversations_appendsToNavigationPath() {
        let sut = makeMyProfileCoordinator()
        sut.goToEventConversations(eventId: "evt1", eventTitle: "Sunset Run")
        XCTAssertEqual(sut.navigationPath, [.eventConversations(eventId: "evt1", eventTitle: "Sunset Run")])
    }

    func test_rootMode_goToSessionSummary_appendsToNavigationPath() {
        let sut = makeMyProfileCoordinator()
        let event = EventFullDetails.fixture()
        sut.goToSessionSummary(evnet: event)
        XCTAssertEqual(sut.navigationPath, [.sessionSummary(event: event)])
    }

    // MARK: - Push: Embedded Mode (onPush set) Delegates Instead of Appending

    func test_embeddedMode_goToOthersEvents_callsOnPushNotNavigationPath() {
        let sut = makeMyProfileCoordinator()
        var pushed: [ProfileRoutePushed] = []
        sut.onPush = { pushed.append($0) }

        sut.goToOthersEvents()

        XCTAssertEqual(pushed, [.othersEvents(userId: "me")])
        XCTAssertTrue(sut.navigationPath.isEmpty, "Embedded coordinators must not also own a navigationPath")
    }

    func test_embeddedMode_goToOthersProfile_callsOnPush() {
        let sut = makeMyProfileCoordinator()
        var pushed: [ProfileRoutePushed] = []
        sut.onPush = { pushed.append($0) }

        sut.goToOthersProfile(userId: "u9")

        XCTAssertEqual(pushed, [.othersProfile(userId: "u9")])
    }

    func test_embeddedMode_multiplePushes_forwardAllInOrder() {
        let sut = makeMyProfileCoordinator()
        var pushed: [ProfileRoutePushed] = []
        sut.onPush = { pushed.append($0) }

        sut.goToMyEvents()
        sut.goToFriendsList()
        sut.goToMyEventDetails(eventId: "evt1")

        XCTAssertEqual(pushed, [
            .myEvents(userId: "me"),
            .friendsList(userId: "me"),
            .myEventDetails(eventId: "evt1")
        ])
    }

    // MARK: - Root-Gated Navigation (myProfile only)

    func test_goToSettings_onMyProfile_pushes() {
        let sut = makeMyProfileCoordinator()
        sut.goToSettings()
        XCTAssertEqual(sut.navigationPath, [.settings])
    }

    func test_goToSettings_onOthersProfile_isNoOp() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "me")
        sut.goToSettings()
        XCTAssertTrue(sut.navigationPath.isEmpty, "Settings should never be reachable from someone else's profile")
    }

    func test_goToFriendRequests_onMyProfile_pushes() {
        let sut = makeMyProfileCoordinator()
        sut.goToFriendRequests()
        XCTAssertEqual(sut.navigationPath, [.friendRequests])
    }

    func test_goToFriendRequests_onOthersProfile_isNoOp() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "me")
        sut.goToFriendRequests()
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    func test_goToHostRequests_onMyProfile_pushes() {
        let sut = makeMyProfileCoordinator()
        sut.goToHostRequests()
        XCTAssertEqual(sut.navigationPath, [.hostRequests])
    }

    func test_goToHostRequests_onOthersProfile_isNoOp() {
        let sut = ProfileCoordinator(userId: "u1", currentUserId: "me")
        sut.goToHostRequests()
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    // MARK: - goToScannedProfile

    func test_goToScannedProfile_withId_pushesAndDismissesSheet() {
        let sut = makeMyProfileCoordinator()
        sut.activeSheet = .qrCode
        sut.goToScannedProfile(userId: "scanned-1")

        XCTAssertEqual(sut.navigationPath, [.scannedProfile(userId: "scanned-1")])
        XCTAssertNil(sut.activeSheet, "Scanning a profile should close the QR sheet")
    }

    func test_goToScannedProfile_withEmptyId_isNoOp() {
        let sut = makeMyProfileCoordinator()
        sut.goToScannedProfile(userId: "")
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    // MARK: - Sheets

    func test_showHostsSheet_setsActiveSheet() {
        let sut = makeMyProfileCoordinator()
        sut.showHostsSheet(eventId: "evt1")
        XCTAssertEqual(sut.activeSheet, .hosts(eventId: "evt1"))
    }

    func test_showQRCode_setsActiveSheet() {
        let sut = makeMyProfileCoordinator()
        sut.showQRCode()
        XCTAssertEqual(sut.activeSheet, .qrCode)
    }

    func test_dismissSheet_clearsActiveSheet() {
        let sut = makeMyProfileCoordinator()
        sut.showQRCode()
        sut.dismissSheet()
        XCTAssertNil(sut.activeSheet)
    }

    // MARK: - switchToProfile

    func test_switchToProfile_updatesUserId() {
        let sut = makeMyProfileCoordinator()
        sut.switchToProfile(userId: "newUser")
        XCTAssertEqual(sut.userId, "newUser")
    }

    func test_switchToProfile_clearsNavigationPath() {
        let sut = makeMyProfileCoordinator()
        sut.goToSettings()
        sut.goToFriendsList()
        sut.switchToProfile(userId: "newUser")
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    func test_switchToProfile_toSelf_resolvesMyProfile() {
        let sut = ProfileCoordinator(userId: "other", currentUserId: "me")
        sut.switchToProfile(userId: "me")
        XCTAssertEqual(sut.rootRoute, .myProfile)
    }

    func test_switchToProfile_toSomeoneElse_resolvesOthersProfile() {
        let sut = makeMyProfileCoordinator() // userId == currentUserId == "me"
        sut.switchToProfile(userId: "stranger")
        XCTAssertEqual(sut.rootRoute, .othersProfile)
    }

    // MARK: - requestLogout

    func test_requestLogout_callsDelegate() {
        let sut = makeMyProfileCoordinator()
        let delegate = MockAuthCoordinatorDelegate()
        sut.delegate = delegate

        sut.requestLogout()

        XCTAssertEqual(delegate.didRequestLogoutCallCount, 1)
    }

    func test_requestLogout_withNoDelegate_doesNotCrash() {
        let sut = makeMyProfileCoordinator()
        sut.requestLogout()
        // No assertion beyond "did not crash" — delegate is nil by default.
    }

    // MARK: - Memory Safety

    func test_coordinator_noMemoryLeak() {
        var coord: ProfileCoordinator? = ProfileCoordinator(userId: "u1", currentUserId: "u1")
        weak var weakCoord = coord
        addTeardownBlock { XCTAssertNil(weakCoord, "ProfileCoordinator leaked") }
        coord = nil
    }

    // MARK: - Helpers

    private func makeMyProfileCoordinator() -> ProfileCoordinator {
        ProfileCoordinator(userId: "me", currentUserId: "me")
    }
}

// MARK: - ProfileRoute

final class ProfileRouteTests: XCTestCase {

    func test_myProfile_equalsMyProfile() {
        XCTAssertEqual(ProfileRoute.myProfile, .myProfile)
    }

    func test_myProfile_notEqualToOthersProfile() {
        XCTAssertNotEqual(ProfileRoute.myProfile, .othersProfile)
    }
}

// MARK: - ProfileRoutePushed

final class ProfileRoutePushedTests: XCTestCase {

    func test_equality_sameCaseSameId_isEqual() {
        XCTAssertEqual(ProfileRoutePushed.myEvents(userId: "u1"), .myEvents(userId: "u1"))
    }

    func test_equality_sameCaseDifferentId_isNotEqual() {
        XCTAssertNotEqual(ProfileRoutePushed.myEvents(userId: "u1"), .myEvents(userId: "u2"))
    }

    func test_equality_differentCases_isNotEqual() {
        XCTAssertNotEqual(ProfileRoutePushed.myEvents(userId: "u1"), .othersEvents(userId: "u1"))
    }

    func test_equality_othersProfileVsScannedProfile_areDistinctCases() {
        // Both carry just a userId, but they're handled differently upstream
        // (scannedProfile always closes the QR sheet first) so they must not unify.
        XCTAssertNotEqual(ProfileRoutePushed.othersProfile(userId: "u1"), .scannedProfile(userId: "u1"))
    }

    func test_equality_eventConversations_comparesBothFields() {
        let a = ProfileRoutePushed.eventConversations(eventId: "e1", eventTitle: "Run")
        let b = ProfileRoutePushed.eventConversations(eventId: "e1", eventTitle: "Run")
        let c = ProfileRoutePushed.eventConversations(eventId: "e1", eventTitle: "Ride")
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func test_equality_sessionSummary_comparesEvent() {
        let event = EventFullDetails.fixture()
        XCTAssertEqual(
            ProfileRoutePushed.sessionSummary(event: event),
            .sessionSummary(event: event)
        )
    }

    func test_hash_equalValues_produceEqualHashes() {
        let a = ProfileRoutePushed.friendsList(userId: "u1")
        let b = ProfileRoutePushed.friendsList(userId: "u1")
        XCTAssertEqual(a.hashValue, b.hashValue)
    }

    func test_usableAsSetElement_deduplicatesEqualRoutes() {
        let set: Set<ProfileRoutePushed> = [.settings, .settings, .friendRequests]
        XCTAssertEqual(set.count, 2)
    }
}

// MARK: - ProfileSheetType

final class ProfileSheetTypeTests: XCTestCase {

    func test_id_hosts_includesEventId() {
        XCTAssertEqual(ProfileSheetType.hosts(eventId: "evt1").id, "hosts-evt1")
    }

    func test_id_qrCode_isStable() {
        XCTAssertEqual(ProfileSheetType.qrCode.id, "qrCode")
    }

    func test_equality_hostsWithSameEventId_isEqual() {
        XCTAssertEqual(ProfileSheetType.hosts(eventId: "evt1"), .hosts(eventId: "evt1"))
    }

    func test_equality_hostsWithDifferentEventId_isNotEqual() {
        XCTAssertNotEqual(ProfileSheetType.hosts(eventId: "evt1"), .hosts(eventId: "evt2"))
    }
}

// MARK: - MockAuthCoordinatorDelegate

/// Shared across ProfileCoordinatorTests and ProfileIntegrationTests.
final class MockAuthCoordinatorDelegate: AuthCoordinatorDelegate {
    var didRequestLogoutCallCount = 0
    var didCompleteSignInCallCount = 0
    var didCompleteProfileSetupCallCount = 0

    func coordinatorDidRequestLogout() { didRequestLogoutCallCount += 1 }
    func coordinatorDidCompleteSignIn() { didCompleteSignInCallCount += 1 }
    func coordinatorDidCompleteProfileSetup() { didCompleteProfileSetupCallCount += 1 }
}
