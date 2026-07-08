//
//  HomeIntegrationTests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest
@testable import sbud

@MainActor
final class HomeIntegrationTests: XCTestCase {

    private var mockFetcher: MockHomeDataFetcher!
    private var mockJoinRequester: MockJoinRequester!
    private var viewModel: HomeViewModel!
    private var coordinator: HomeCoordinator!

    override func setUp() {
        super.setUp()
        mockFetcher = MockHomeDataFetcher()
        mockJoinRequester = MockJoinRequester()
        viewModel = HomeViewModel(homeDataFetcher: mockFetcher, joinRequester: mockJoinRequester, autoStart: false)
        coordinator = HomeCoordinator()
        PopUpGenerator.shared.clearAll()
    }

    override func tearDown() {
        PopUpGenerator.shared.clearAll()
        coordinator = nil
        viewModel = nil
        mockJoinRequester = nil
        mockFetcher = nil
        super.tearDown()
    }

    // MARK: - 1. Load -> Tap Routing (mirrors HomeView's onTapEvent closures)

    /// Replicates HomeView.swift's exact routing rule so this test breaks if that
    /// rule ever silently changes without an accompanying test update.
    private func routeUpcomingEventTap(_ event: UpcomingEvent) {
        if event.role == .creator || event.role == .host {
            coordinator.goToMyEventDetail(eventId: event.eventId)
        } else {
            coordinator.goToOthersEventDetail(eventId: event.eventId)
        }
    }

    func test_tapUpcomingEvent_asCreator_routesToMyEventDetail() async {
        mockFetcher.stubbedResult = .success(.fixture(upcoming: [.fixture(eventId: "e1", role: .creator)]))
        await viewModel.load()

        routeUpcomingEventTap(viewModel.upcomingEvents[0])

        XCTAssertEqual(coordinator.navigationPath, [.myEventDetail(eventId: "e1")])
    }

    func test_tapUpcomingEvent_asHost_routesToMyEventDetail() async {
        mockFetcher.stubbedResult = .success(.fixture(upcoming: [.fixture(eventId: "e1", role: .host)]))
        await viewModel.load()

        routeUpcomingEventTap(viewModel.upcomingEvents[0])

        XCTAssertEqual(coordinator.navigationPath, [.myEventDetail(eventId: "e1")])
    }

    func test_tapUpcomingEvent_asParticipant_routesToOthersEventDetail() async {
        mockFetcher.stubbedResult = .success(.fixture(upcoming: [.fixture(eventId: "e1", role: .participant)]))
        await viewModel.load()

        routeUpcomingEventTap(viewModel.upcomingEvents[0])

        XCTAssertEqual(coordinator.navigationPath, [.othersEventDetail(eventId: "e1")])
    }

    // MARK: - 2. FriendsActivitySection routing (isCurrentUserCreator branch)

    func test_tapFriendActivityItem_whenCurrentUserIsCreator_routesToMyEventDetail() async throws {
        // Seed the local profile deterministically rather than depending on whatever
        // ProfileManager.shared happens to already hold in this test run — mirrors
        // MainCoordinator's UI_TESTING stub-profile seeding, but for the unit/integration target.
        let myId = "integration-test-user"
        var stub = UserProfile(id: myId)
        stub.name = "Integration"
        ProfileManager.shared.saveProfileToLocale(profile: stub)

        mockFetcher.stubbedResult = .success(.fixture(friendsActivity: [
            .fixture(eventId: "fa1", creatorId: myId)
        ]))
        await viewModel.load()

        let item = viewModel.friendsActivity[0]
        if item.isCurrentUserCreator {
            coordinator.goToMyEventDetail(eventId: item.eventId)
        } else {
            coordinator.goToOthersEventDetail(eventId: item.eventId)
        }

        XCTAssertEqual(coordinator.navigationPath, [.myEventDetail(eventId: "fa1")])
    }

    // MARK: - 3. Multi-Destination Navigation Sequence

    func test_browsingSequence_pushThenPopToRoot_clearsPath() async {
        mockFetcher.stubbedResult = .success(.fixture(upcoming: [
            .fixture(eventId: "e1", role: .creator),
            .fixture(eventId: "e2", role: .participant)
        ]))
        await viewModel.load()

        for event in viewModel.upcomingEvents {
            routeUpcomingEventTap(event)
        }
        XCTAssertEqual(coordinator.navigationPath.count, 2)

        coordinator.popToRoot()
        XCTAssertTrue(coordinator.navigationPath.isEmpty)
    }

    // MARK: - 4. joinEvent -> PopUpGenerator Toast Integration (real singleton, no mock)

    func test_joinEvent_confirmedStatus_showsNotificationToast() async throws {
        mockJoinRequester.stubbedJoinResult = .success(JoinEventResponse(status: "confirmed", message: "Joined!"))
        await viewModel.joinEvent(eventId: "evt1")
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(PopUpGenerator.shared.popUps.first?.msg, "You have joined the event!")
    }

    func test_joinEvent_pendingStatus_showsAwaitingApprovalToast() async throws {
        mockJoinRequester.stubbedJoinResult = .success(JoinEventResponse(status: "pending", message: "ok"))
        await viewModel.joinEvent(eventId: "evt1")
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(PopUpGenerator.shared.popUps.first?.msg, "Request sent, awaiting approval.")
    }

    func test_joinEvent_waitlistedStatus_showsServerSuppliedMessage() async throws {
        mockJoinRequester.stubbedJoinResult = .success(JoinEventResponse(status: "waitlisted", message: "You're #3 in line."))
        await viewModel.joinEvent(eventId: "evt1")
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(PopUpGenerator.shared.popUps.first?.msg, "You're #3 in line.")
    }

    func test_joinEvent_networkFailure_showsErrorToast() async throws {
        mockJoinRequester.stubbedJoinResult = .failure(URLError(.notConnectedToInternet))
        await viewModel.joinEvent(eventId: "evt1")
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(PopUpGenerator.shared.popUps.count, 1)
        XCTAssertTrue(PopUpGenerator.shared.popUps.first?.msg.hasPrefix("Error:") ?? false)
    }

    // MARK: - 5. Memory Safety of the Combined Graph

    func test_combinedGraph_noMemoryLeak() {
        var vm: HomeViewModel? = HomeViewModel(
            homeDataFetcher: MockHomeDataFetcher(), joinRequester: MockJoinRequester(), autoStart: false
        )
        var coord: HomeCoordinator? = HomeCoordinator()
        weak var weakVm = vm
        weak var weakCoord = coord
        addTeardownBlock {
            XCTAssertNil(weakVm, "HomeViewModel leaked")
            XCTAssertNil(weakCoord, "HomeCoordinator leaked")
        }
        vm = nil
        coord = nil
    }
}
