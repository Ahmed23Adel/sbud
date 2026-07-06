//
//  StoriesHelperServiceTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 06/07/2026.
//


import XCTest
@testable import sbud

final class StoriesHelperServiceTests: XCTestCase {

    private var repo: MockStoriesRepository!
    private var sut: StoriesHelperService!

    private let myUserId = "me_123"

    override func setUp() {
        super.setUp()
        repo = MockStoriesRepository()
        sut = StoriesHelperService(
            storiesRepo: repo,
            currentUserIdProvider: { [myUserId] in myUserId }
        )
    }

    override func tearDown() {
        sut = nil
        repo = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeStory(id: String,
                           userId: String,
                           authorName: String? = nil,
                           reactions: [String: String] = [:]) -> Story {
        Story(
            id: id, userId: userId, authorName: authorName,
            authorProfileImageUrl: nil, eventId: nil, eventName: nil,
            eventImage: nil, activityType: nil, images: [], text: nil,
            reactions: reactions, createdAt: Date(), expiresAt: nil,
            myReaction: nil
        )
    }

    private func setFeed(_ stories: [Story]) {
        repo.feedToReturn = StoriesFeedResponse(stories: stories, total: stories.count, hasMore: false)
    }

    // MARK: - Raggruppamento

    func test_fetch_groupsStoriesByUser() async throws {
        setFeed([
            makeStory(id: "s1", userId: "friendA"),
            makeStory(id: "s2", userId: "friendA"),
            makeStory(id: "s3", userId: "friendB")
        ])

        let (friends, _) = try await sut.fetchFriendsWithStoriesAndOwn()

        XCTAssertEqual(friends.count, 2)
        let friendA = friends.first { $0.id == "friendA" }
        XCTAssertEqual(friendA?.stories.map(\.id), ["s1", "s2"],
                       "Le storie dello stesso utente vanno raggruppate mantenendo l'ordine del feed")
    }

    func test_fetch_emptyFeed_returnsEmptyResults() async throws {
        setFeed([])

        let (friends, own) = try await sut.fetchFriendsWithStoriesAndOwn()

        XCTAssertTrue(friends.isEmpty)
        XCTAssertTrue(own.isEmpty)
    }

    // MARK: - Storie proprie separate

    func test_fetch_separatesOwnStoriesFromFriends() async throws {
        setFeed([
            makeStory(id: "mine1", userId: myUserId),
            makeStory(id: "theirs1", userId: "friendA"),
            makeStory(id: "mine2", userId: myUserId)
        ])

        let (friends, own) = try await sut.fetchFriendsWithStoriesAndOwn()

        XCTAssertEqual(own.map(\.id), ["mine1", "mine2"])
        XCTAssertEqual(friends.count, 1)
        XCTAssertEqual(friends.first?.id, "friendA")
    }

    func test_fetch_onlyOwnStories_friendsListIsEmpty() async throws {
        setFeed([makeStory(id: "mine1", userId: myUserId)])

        let (friends, own) = try await sut.fetchFriendsWithStoriesAndOwn()

        XCTAssertTrue(friends.isEmpty)
        XCTAssertEqual(own.count, 1)
    }

    // MARK: - myReaction

    func test_fetch_setsMyReactionFromReactionsMap() async throws {
        setFeed([
            makeStory(id: "s1", userId: "friendA",
                      reactions: [myUserId: "🔥", "altro_utente": "😂"])
        ])

        let (friends, _) = try await sut.fetchFriendsWithStoriesAndOwn()

        XCTAssertEqual(friends.first?.stories.first?.myReaction, "🔥",
                       "myReaction deve essere la reazione dell'utente corrente")
    }

    func test_fetch_noReactionFromMe_myReactionIsNil() async throws {
        setFeed([
            makeStory(id: "s1", userId: "friendA",
                      reactions: ["altro_utente": "😂"])
        ])

        let (friends, _) = try await sut.fetchFriendsWithStoriesAndOwn()

        XCTAssertNil(friends.first?.stories.first?.myReaction)
    }

    func test_fetch_setsMyReactionAlsoOnOwnStories() async throws {
        setFeed([
            makeStory(id: "mine", userId: myUserId, reactions: [myUserId: "❤️"])
        ])

        let (_, own) = try await sut.fetchFriendsWithStoriesAndOwn()

        XCTAssertEqual(own.first?.myReaction, "❤️")
    }

    // MARK: - Nome amico

    func test_fetch_usesAuthorNameWhenAvailable() async throws {
        setFeed([makeStory(id: "s1", userId: "friendA", authorName: "Ahmed")])

        let (friends, _) = try await sut.fetchFriendsWithStoriesAndOwn()

        XCTAssertEqual(friends.first?.name, "Ahmed")
    }

    func test_fetch_fallsBackToUserIdWhenNameIsNil() async throws {
        setFeed([makeStory(id: "s1", userId: "friendA", authorName: nil)])

        let (friends, _) = try await sut.fetchFriendsWithStoriesAndOwn()

        XCTAssertEqual(friends.first?.name, "friendA",
                       "Senza authorName deve usare lo userId come nome")
    }

    // MARK: - Ordinamento

    func test_fetch_sortsFriendsAlphabeticallyByName() async throws {
        setFeed([
            makeStory(id: "s1", userId: "u1", authorName: "Zoe"),
            makeStory(id: "s2", userId: "u2", authorName: "Ahmed"),
            makeStory(id: "s3", userId: "u3", authorName: "Marco")
        ])

        let (friends, _) = try await sut.fetchFriendsWithStoriesAndOwn()

        XCTAssertEqual(friends.map(\.name), ["Ahmed", "Marco", "Zoe"])
    }

    // MARK: - fetchFriendsWithStories (wrapper)

    func test_fetchFriendsWithStories_returnsOnlyFriends() async throws {
        setFeed([
            makeStory(id: "mine", userId: myUserId),
            makeStory(id: "theirs", userId: "friendA")
        ])

        let friends = try await sut.fetchFriendsWithStories()

        XCTAssertEqual(friends.count, 1)
        XCTAssertEqual(friends.first?.id, "friendA")
    }

    // MARK: - Errori

    func test_fetch_repoThrows_propagatesError() async {
        repo.shouldThrow = true

        do {
            _ = try await sut.fetchFriendsWithStoriesAndOwn()
            XCTFail("Doveva lanciare un errore")
        } catch {
            // ok, l'errore del repository deve propagarsi al chiamante
        }
    }
}
