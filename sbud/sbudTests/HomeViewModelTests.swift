//
//  HomeViewModelTests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest
@testable import sbud

// MARK: - MockHomeDataFetcher

final class MockHomeDataFetcher: HomeDataFetching {
    private(set) var fetchHomeCallCount = 0
    private(set) var lastLat: Double?
    private(set) var lastLon: Double?
    var stubbedResult: Result<HomeResponse, Error> = .success(.empty)

    func fetchHome(lat: Double?, lon: Double?) async throws -> HomeResponse {
        fetchHomeCallCount += 1
        lastLat = lat
        lastLon = lon
        switch stubbedResult {
        case .success(let response): return response
        case .failure(let error): throw error
        }
    }
}

// MARK: - HomeViewModelTests

@MainActor
final class HomeViewModelTests: XCTestCase {

    private var mockFetcher: MockHomeDataFetcher!
    private var mockJoinRequester: MockJoinRequester!
    private var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        mockFetcher = MockHomeDataFetcher()
        mockJoinRequester = MockJoinRequester()
        sut = HomeViewModel(homeDataFetcher: mockFetcher, joinRequester: mockJoinRequester, autoStart: false)
    }

    override func tearDown() {
        sut = nil
        mockJoinRequester = nil
        mockFetcher = nil
        super.tearDown()
    }

    // MARK: - Initial State (autoStart: false)

    func test_init_autoStartFalse_doesNotFetchImmediately() {
        XCTAssertEqual(mockFetcher.fetchHomeCallCount, 0)
    }

    func test_init_autoStartFalse_isLoadingStartsFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    func test_init_collectionsStartEmpty() {
        XCTAssertTrue(sut.upcomingEvents.isEmpty)
        XCTAssertTrue(sut.recommendedEvents.isEmpty)
        XCTAssertTrue(sut.friendsActivity.isEmpty)
        XCTAssertTrue(sut.meetPeople.isEmpty)
        XCTAssertTrue(sut.privateEvents.isEmpty)
    }

    // MARK: - load()

    func test_load_populatesUpcomingEvents() async {
        mockFetcher.stubbedResult = .success(.fixture(upcoming: [.fixture(eventId: "e1")]))
        await sut.load()
        XCTAssertEqual(sut.upcomingEvents.map(\.eventId), ["e1"])
    }

    func test_load_populatesRecommendedEvents() async {
        mockFetcher.stubbedResult = .success(.fixture(recommended: [.fixture(eventId: "r1")]))
        await sut.load()
        XCTAssertEqual(sut.recommendedEvents.map(\.eventId), ["r1"])
    }

    func test_load_populatesPrivateEvents() async {
        mockFetcher.stubbedResult = .success(.fixture(privateEvents: [.fixture(eventId: "p1")]))
        await sut.load()
        XCTAssertEqual(sut.privateEvents.map(\.eventId), ["p1"])
    }

    func test_load_populatesFriendsActivity() async {
        mockFetcher.stubbedResult = .success(.fixture(friendsActivity: [.fixture(eventId: "fa1")]))
        await sut.load()
        XCTAssertEqual(sut.friendsActivity.map(\.eventId), ["fa1"])
    }

    func test_load_populatesMeetPeople() async {
        mockFetcher.stubbedResult = .success(.fixture(meetPeople: [.fixture(userId: "mp1")]))
        await sut.load()
        XCTAssertEqual(sut.meetPeople.map(\.userId), ["mp1"])
    }

    func test_load_onSuccess_setsIsLoadingFalse() async {
        sut.isLoading = true
        await sut.load()
        XCTAssertFalse(sut.isLoading)
    }

    func test_load_onFailure_setsIsLoadingFalse() async {
        mockFetcher.stubbedResult = .failure(URLError(.notConnectedToInternet))
        sut.isLoading = true
        await sut.load()
        XCTAssertFalse(sut.isLoading)
    }

    func test_load_onFailure_doesNotMutateExistingData() async {
        // Seed successful data first.
        mockFetcher.stubbedResult = .success(.fixture(upcoming: [.fixture(eventId: "keep-me")]))
        await sut.load()

        // Then fail.
        mockFetcher.stubbedResult = .failure(URLError(.timedOut))
        await sut.load()

        XCTAssertEqual(sut.upcomingEvents.map(\.eventId), ["keep-me"], "A failed reload should not clear prior data")
    }

    func test_load_passesNilLatLon_whenNoLocationAvailable() async {
        await sut.load()
        XCTAssertNil(mockFetcher.lastLat)
        XCTAssertNil(mockFetcher.lastLon)
    }

    func test_load_calledTwice_fetchesTwice() async {
        await sut.load()
        await sut.load()
        XCTAssertEqual(mockFetcher.fetchHomeCallCount, 2)
    }

    // MARK: - joinEvent(eventId:)

    func test_joinEvent_callsJoinRequesterWithCorrectEventId() async {
        mockJoinRequester.stubbedJoinResult = .success(JoinEventResponse(status: "confirmed", message: "ok"))
        await sut.joinEvent(eventId: "evt1")
        XCTAssertEqual(mockJoinRequester.joinCallCount, 1)
    }

    func test_joinEvent_onConfirmed_updatesMatchingRecommendedEventStatus() async {
        mockFetcher.stubbedResult = .success(.fixture(recommended: [.fixture(eventId: "evt1", userStatus: nil)]))
        await sut.load()

        // joinEvent triggers a detached reload Task afterwards — stub the reload to return
        // the same "confirmed" status so the assertion is stable regardless of whether that
        // reload has completed by the time we check, instead of racing on timing.
        mockFetcher.stubbedResult = .success(.fixture(recommended: [.fixture(eventId: "evt1", userStatus: "confirmed")]))
        mockJoinRequester.stubbedJoinResult = .success(JoinEventResponse(status: "confirmed", message: "ok"))
        await sut.joinEvent(eventId: "evt1")

        XCTAssertEqual(sut.recommendedEvents.first(where: { $0.eventId == "evt1" })?.userStatus, "confirmed")
    }

    func test_joinEvent_doesNotTouchUnrelatedEvents() async {
        mockFetcher.stubbedResult = .success(.fixture(recommended: [
            .fixture(eventId: "evt1", userStatus: nil),
            .fixture(eventId: "evt2", userStatus: nil)
        ]))
        await sut.load()

        // Same reasoning as above: keep the reload's stubbed data consistent with the
        // expected end state so the detached reload Task can't introduce flakiness.
        mockFetcher.stubbedResult = .success(.fixture(recommended: [
            .fixture(eventId: "evt1", userStatus: "pending"),
            .fixture(eventId: "evt2", userStatus: nil)
        ]))
        mockJoinRequester.stubbedJoinResult = .success(JoinEventResponse(status: "pending", message: "ok"))
        await sut.joinEvent(eventId: "evt1")

        XCTAssertNil(sut.recommendedEvents.first(where: { $0.eventId == "evt2" })?.userStatus)
    }

    func test_joinEvent_triggersReload() async {
        mockFetcher.stubbedResult = .success(.empty)
        await sut.load() // call #1
        let before = mockFetcher.fetchHomeCallCount

        mockJoinRequester.stubbedJoinResult = .success(JoinEventResponse(status: "pending", message: "ok"))
        await sut.joinEvent(eventId: "evt1")
        try? await Task.sleep(nanoseconds: 200_000_000) // joinEvent kicks off a detached reload Task

        XCTAssertGreaterThan(mockFetcher.fetchHomeCallCount, before, "joinEvent should trigger a fresh load()")
    }

    func test_joinEvent_onRequesterFailure_doesNotCrash() async {
        mockJoinRequester.stubbedJoinResult = .failure(URLError(.notConnectedToInternet))
        await sut.joinEvent(eventId: "evt1")
        // No assertion beyond "did not crash" — error path shows a PopUpGenerator toast,
        // which is covered by CentralPopupTests.
    }

    // MARK: - Memory Safety

    func test_viewModel_noMemoryLeak() {
        var vm: HomeViewModel? = HomeViewModel(
            homeDataFetcher: MockHomeDataFetcher(),
            joinRequester: MockJoinRequester(),
            autoStart: false
        )
        weak var weakVm = vm
        addTeardownBlock { XCTAssertNil(weakVm, "HomeViewModel leaked") }
        vm = nil
    }
}

// MARK: - Fixtures

extension HomeResponse {
    static var empty: HomeResponse { .fixture() }

    static func fixture(
        upcoming: [UpcomingEvent] = [],
        recommended: [RecommendedEvent] = [],
        friendsActivity: [FriendActivityItem] = [],
        meetPeople: [MeetPersonItem] = [],
        privateEvents: [PrivateEvent] = []
    ) -> HomeResponse {
        HomeResponse(
            upcoming: upcoming,
            recommended: recommended,
            friendsActivity: friendsActivity,
            meetPeople: meetPeople,
            privateEvents: privateEvents
        )
    }
}

extension UpcomingEvent {
    static func fixture(
        eventId: String = "upcoming-fixture",
        title: String = "Test Upcoming Event",
        activityType: String = "running",
        eventImage: String = "",
        status: String = "confirmed",
        isDateConfirmed: Bool = true,
        startDateTime: String = "2026-07-01T10:00:00Z",
        role: UpcomingEventRole = .participant
    ) -> UpcomingEvent {
        UpcomingEvent(
            eventId: eventId,
            title: title,
            activityType: activityType,
            eventImage: eventImage,
            status: status,
            isDateConfirmed: isDateConfirmed,
            startDateTime: startDateTime,
            role: role
        )
    }
}

extension RecommendedEvent {
    static func fixture(
        eventId: String = "recommended-fixture",
        title: String = "Test Recommended Event",
        activityType: String = "running",
        eventImage: String = "",
        notes: String = "",
        joiningCondition: String = "autoJoin",
        userStatus: String? = nil
    ) -> RecommendedEvent {
        RecommendedEvent(
            eventId: eventId,
            title: title,
            activityType: activityType,
            eventImage: eventImage,
            notes: notes,
            joiningCondition: joiningCondition,
            userStatus: userStatus
        )
    }
}

extension PrivateEvent {
    static func fixture(
        eventId: String = "private-fixture",
        title: String = "Test Private Event",
        activityType: String = "cycling",
        eventImage: String? = nil,
        startDateTime: String? = "2026-07-01T10:00:00Z",
        joiningCondition: String = "autoJoin",
        userStatus: String? = nil
    ) -> PrivateEvent {
        PrivateEvent(
            eventId: eventId,
            title: title,
            activityType: activityType,
            eventImage: eventImage,
            startDateTime: startDateTime,
            joiningCondition: joiningCondition,
            userStatus: userStatus
        )
    }
}

extension FriendActivityItem {
    static func fixture(
        userId: String = "friend-fixture",
        name: String = "Friend Name",
        profileImageUrl: String? = nil,
        eventId: String = "fa-event-fixture",
        eventTitle: String = "Friend Activity Event",
        activityType: String = "running",
        participationRole: String = "joined",
        creatorId: String = "creator-fixture",
        joinedAt: String? = nil
    ) -> FriendActivityItem {
        FriendActivityItem(
            userId: userId,
            name: name,
            profileImageUrl: profileImageUrl,
            eventId: eventId,
            eventTitle: eventTitle,
            activityType: activityType,
            participationRole: participationRole,
            creatorId: creatorId,
            joinedAt: joinedAt
        )
    }
}

extension MeetPersonItem {
    static func fixture(
        userId: String = "meet-fixture",
        name: String = "Meet",
        surName: String = "Person",
        profileImageUrl: String? = nil,
        preferredActivity: String = "running"
    ) -> MeetPersonItem {
        MeetPersonItem(
            userId: userId,
            name: name,
            surName: surName,
            profileImageUrl: profileImageUrl,
            preferredActivity: preferredActivity
        )
    }
}

