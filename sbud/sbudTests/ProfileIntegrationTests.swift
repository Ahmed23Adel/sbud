//
//  ProfileIntegrationTests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest
@testable import sbud

@MainActor
final class ProfileIntegrationTests: XCTestCase {

    // MARK: - 1. Embedded-Mode Bridge (mirrors HomeAppCoordinator.handleProfileRoute)

    /// Mirrors HomeAppCoordinator.swift's private `handleProfileRoute(_:)` switch.
    /// Kept here as an executable spec: if that routing table ever changes without a
    /// matching update to this helper, these tests will catch the drift.
    private func bridgeIntoParent(_ route: ProfileRoutePushed, parent: HomeCoordinator) {
        switch route {
        case .othersProfile(let userId), .scannedProfile(let userId):
            parent.goToProfile(userId: userId)
        case .myEventDetails(let eventId):
            parent.goToMyEventDetail(eventId: eventId)
        case .othersEventDetails(let eventId):
            parent.goToOthersEventDetail(eventId: eventId)
        case .friendsList(let userId):
            parent.goToFriendsList(userId: userId)
        case .othersEvents(let userId):
            parent.goToOthersEvents(userId: userId)
        case .myEvents(let userId):
            parent.goToMyEvents(userId: userId)
        default:
            break
        }
    }

    func test_embeddedProfile_scannedQRCode_bridgesIntoParentHomeCoordinator() {
        let parent = HomeCoordinator()
        let profile = ProfileCoordinator(userId: "me", currentUserId: "me")
        profile.onPush = { [weak parent] route in
            guard let parent else { return }
            self.bridgeIntoParent(route, parent: parent)
        }

        profile.activeSheet = .qrCode
        profile.goToScannedProfile(userId: "scanned-stranger")

        XCTAssertNil(profile.activeSheet, "QR sheet should close before bridging")
        XCTAssertTrue(profile.navigationPath.isEmpty, "Embedded coordinator should never grow its own path")
        XCTAssertEqual(parent.navigationPath, [.profileView(userId: "scanned-stranger")])
    }

    func test_embeddedProfile_goToMyEventDetails_bridgesIntoParent() {
        let parent = HomeCoordinator()
        let profile = ProfileCoordinator(userId: "me", currentUserId: "me")
        profile.onPush = { [weak parent] route in
            guard let parent else { return }
            self.bridgeIntoParent(route, parent: parent)
        }

        profile.goToMyEventDetails(eventId: "evt1")

        XCTAssertEqual(parent.navigationPath, [.myEventDetail(eventId: "evt1")])
    }

    func test_embeddedProfile_multiStepBrowsing_forwardsEachHopInOrder() {
        let parent = HomeCoordinator()
        let profile = ProfileCoordinator(userId: "me", currentUserId: "me")
        profile.onPush = { [weak parent] route in
            guard let parent else { return }
            self.bridgeIntoParent(route, parent: parent)
        }

        profile.goToFriendsList()
        profile.goToOthersProfile(userId: "friend-1")
        profile.goToOthersEventDetails(eventId: "evt-from-friend")

        XCTAssertEqual(parent.navigationPath, [
            .friendsList(userId: "me"),
            .profileView(userId: "friend-1"),
            .othersEventDetail(eventId: "evt-from-friend")
        ])
    }

    // MARK: - 2. Root-Mode Sequence (tab-root usage, owns its own path)

    func test_rootMode_fullBrowsingSession_pushThenPopToRoot() {
        let sut = ProfileCoordinator(userId: "me", currentUserId: "me")

        sut.goToFriendsList()
        sut.goToOthersProfile(userId: "friend-1")
        sut.goToSettings() // gated by rootRoute, which is still .myProfile (the coordinator's
                            // own rootRoute doesn't change just because we pushed someone
                            // else's profile onto the stack — only switchToProfile changes it)

        XCTAssertEqual(sut.navigationPath.count, 3)

        sut.popToRoot()
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    // MARK: - 3. switchToProfile Changes the Gating Contract Mid-Session

    func test_switchToProfile_fromOwnToStranger_blocksSettingsAfterwards() {
        let sut = ProfileCoordinator(userId: "me", currentUserId: "me")
        sut.goToSettings()
        XCTAssertEqual(sut.navigationPath, [.settings], "Sanity check: settings reachable before switching")

        sut.switchToProfile(userId: "stranger")
        XCTAssertEqual(sut.rootRoute, .othersProfile)
        XCTAssertTrue(sut.navigationPath.isEmpty, "switchToProfile resets the path")

        sut.goToSettings()
        XCTAssertTrue(sut.navigationPath.isEmpty, "Settings must stay unreachable once viewing someone else's profile")
    }

    func test_switchToProfile_backToSelf_restoresSettingsAccess() {
        let sut = ProfileCoordinator(userId: "stranger", currentUserId: "me")
        XCTAssertEqual(sut.rootRoute, .othersProfile)

        sut.switchToProfile(userId: "me")
        XCTAssertEqual(sut.rootRoute, .myProfile)

        sut.goToSettings()
        XCTAssertEqual(sut.navigationPath, [.settings])
    }

    // MARK: - 4. Logout Flow End-to-End (coordinator -> delegate)

    func test_logoutFlow_fromDeepNavigationState_stillReachesDelegate() {
        let sut = ProfileCoordinator(userId: "me", currentUserId: "me")
        let delegate = MockAuthCoordinatorDelegate()
        sut.delegate = delegate

        sut.goToFriendsList()
        sut.goToSettings()
        sut.requestLogout()

        XCTAssertEqual(delegate.didRequestLogoutCallCount, 1)
        // Logging out doesn't itself clear navigation — that's MainCoordinator's job
        // once it swaps currentRoute away from .home. Confirms ProfileCoordinator stays
        // narrowly scoped to its own navigation concerns.
        XCTAssertEqual(sut.navigationPath.count, 2)
    }

    // MARK: - 5. Sheets Survive Independently of Push Navigation

    func test_hostsSheet_independentOfNavigationPath() {
        let sut = ProfileCoordinator(userId: "me", currentUserId: "me")
        sut.goToFriendsList()
        sut.showHostsSheet(eventId: "evt1")

        XCTAssertEqual(sut.activeSheet, .hosts(eventId: "evt1"))
        XCTAssertEqual(sut.navigationPath.count, 1, "Opening a sheet must not affect the push stack")

        sut.dismissSheet()
        XCTAssertNil(sut.activeSheet)
        XCTAssertEqual(sut.navigationPath.count, 1, "Dismissing a sheet must not affect the push stack")
    }
}
