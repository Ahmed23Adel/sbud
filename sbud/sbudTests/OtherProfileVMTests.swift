//
//  OtherProfileVMTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

@MainActor
final class OtherProfileVMTests: XCTestCase {

    private var mockUserRepo: MockUserProfileFetching!
    private var mockFriendRepo: MockFriendRepository!
    private var mockUserProvider: MockCurrentUserProvider!
    private var sut: OtherProfileVM!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserProfileFetching()
        mockFriendRepo = MockFriendRepository()
        mockUserProvider = MockCurrentUserProvider()
        mockUserProvider.currentUserId = "me"
        let friendManager = FriendManager(repository: mockFriendRepo, currentUserProvider: mockUserProvider)
        sut = OtherProfileVM(userId: "target", userRepository: mockUserRepo, friendManager: friendManager)
    }

    override func tearDown() {
        sut = nil; mockUserProvider = nil; mockFriendRepo = nil; mockUserRepo = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func test_init_friendStatusStartsNotFriend() {
        XCTAssertEqual(sut.friendStatus, .notFriend)
        XCTAssertFalse(sut.isFriend)
        XCTAssertFalse(sut.isRequestSent)
        XCTAssertFalse(sut.isRequestReceived)
    }

    // MARK: - refreshFriendStatus

    func test_refreshFriendStatus_friends() async {
        mockFriendRepo.getFriendStatusResult = .success(.friends)
        await sut.refreshFriendStatus()
        XCTAssertEqual(sut.friendStatus, .friends)
        XCTAssertTrue(sut.isFriend)
    }

    func test_refreshFriendStatus_requestSent() async {
        mockFriendRepo.getFriendStatusResult = .success(.requestSent)
        await sut.refreshFriendStatus()
        XCTAssertTrue(sut.isRequestSent)
    }

    func test_refreshFriendStatus_requestReceived() async {
        mockFriendRepo.getFriendStatusResult = .success(.requestReceived)
        await sut.refreshFriendStatus()
        XCTAssertTrue(sut.isRequestReceived)
    }

    // MARK: - toggleFriendAction: notFriend → open account → friends

    func test_toggleFriendAction_notFriend_openAccount_becomesFriends() async {
        var profile = UserProfile(id: "target")
        profile.isPrivate = false
        profile.friendsCount = 5
        sut.profile = profile
        await sut.toggleFriendAction()
        XCTAssertEqual(sut.friendStatus, .friends)
        let count = sut.profile?.friendsCount ?? 0
        XCTAssertEqual(count, 6)
        XCTAssertEqual(mockFriendRepo.addFriendDirectlyCalls.count, 1)
    }

    // MARK: - toggleFriendAction: notFriend → private → requestSent

    func test_toggleFriendAction_notFriend_private_becomesRequestSent() async {
        var profile = UserProfile(id: "target")
        profile.isPrivate = true
        sut.profile = profile
        await sut.toggleFriendAction()
        XCTAssertEqual(sut.friendStatus, .requestSent)
        XCTAssertEqual(mockFriendRepo.sendFriendRequestCalls.count, 1)
    }

    // MARK: - toggleFriendAction: requestSent → cancel → notFriend

    func test_toggleFriendAction_requestSent_cancels() async {
        mockFriendRepo.getFriendStatusResult = .success(.requestSent)
        await sut.refreshFriendStatus()
        await sut.toggleFriendAction()
        XCTAssertEqual(sut.friendStatus, .notFriend)
        XCTAssertEqual(mockFriendRepo.cancelFriendRequestCalls.count, 1)
    }

    // MARK: - toggleFriendAction: requestReceived → accept → friends

    func test_toggleFriendAction_requestReceived_accepts() async {
        var profile = UserProfile(id: "target")
        profile.friendsCount = 2
        sut.profile = profile
        mockFriendRepo.getFriendStatusResult = .success(.requestReceived)
        await sut.refreshFriendStatus()
        await sut.toggleFriendAction()
        XCTAssertEqual(sut.friendStatus, .friends)
        let count = sut.profile?.friendsCount ?? 0
        XCTAssertEqual(count, 3)
    }

    // MARK: - toggleFriendAction: friends → remove → notFriend

    func test_toggleFriendAction_friends_removes() async {
        var profile = UserProfile(id: "target")
        profile.friendsCount = 3
        sut.profile = profile
        mockFriendRepo.getFriendStatusResult = .success(.friends)
        await sut.refreshFriendStatus()
        await sut.toggleFriendAction()
        XCTAssertEqual(sut.friendStatus, .notFriend)
        let count = sut.profile?.friendsCount ?? 0
        XCTAssertEqual(count, 2)
    }

    func test_toggleFriendAction_friends_removingAtZero_neverGoesNegative() async {
        var profile = UserProfile(id: "target")
        profile.friendsCount = 0
        sut.profile = profile
        mockFriendRepo.getFriendStatusResult = .success(.friends)
        await sut.refreshFriendStatus()
        await sut.toggleFriendAction()
        let count = sut.profile?.friendsCount ?? -1
        XCTAssertEqual(count, 0)
    }

    // MARK: - Re-entrancy guard

    func test_toggleFriendAction_isFriendActionLoading_falseAfterCompletion() async {
        var profile = UserProfile(id: "target")
        profile.isPrivate = false
        sut.profile = profile
        await sut.toggleFriendAction()
        XCTAssertFalse(sut.isFriendActionLoading)
    }

    // MARK: - Error handling

    func test_toggleFriendAction_repositoryError_setsErrorMessage() async {
        var profile = UserProfile(id: "target")
        profile.isPrivate = false
        sut.profile = profile
        mockFriendRepo.addFriendDirectlyResult = .failure(URLError(.notConnectedToInternet))
        await sut.toggleFriendAction()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.friendStatus, .notFriend)
    }
}
