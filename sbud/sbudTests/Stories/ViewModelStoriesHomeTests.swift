//
//  ViewModelStoriesHomeTests.swift
//  sbudTests
//
//  Created by Riccardo Maria Cadario on 03/07/2026.
//
import XCTest
@testable import sbud

@MainActor
final class ViewModelStoriesHomeTests: XCTestCase {

    var sut: ViewModelStoriesHome!

    override func setUp() {
        super.setUp()
        sut = ViewModelStoriesHome()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_updateStories_removesFriend_ifRemainingIsEmpty() {
        // Arrange
        // Creiamo una finta Story inserendo tutti i parametri richiesti dal tuo init
        let dummyStory = Story(
            id: "story_1",
            userId: "user_1",
            authorName: nil,
            authorProfileImageUrl: nil,
            eventId: nil,
            eventName: nil,
            eventImage: nil,
            activityType: nil,
            images: [],
            text: nil,
            reactions: [:],
            createdAt: Date(),
            expiresAt: nil,
            myReaction: nil
        )
        
        let mockFriend = FriendWithStories(id: "user_1", name: "Ahmed", profileImageUrl: nil, stories: [dummyStory])
        sut.friendsWithStories = [mockFriend]
        
        // Act
        sut.updateStories(for: "user_1", remaining: [])
        
        // Assert
        XCTAssertTrue(sut.friendsWithStories.isEmpty, "L'amico deve essere rimosso dalla lista se non ha più storie")
    }

    func test_updateMyStories_updatesProperty() {
        // Arrange
        let dummyStory = Story(
            id: "my_story_1",
            userId: "me",
            authorName: nil,
            authorProfileImageUrl: nil,
            eventId: nil,
            eventName: nil,
            eventImage: nil,
            activityType: nil,
            images: [],
            text: nil,
            reactions: [:],
            createdAt: Date(),
            expiresAt: nil,
            myReaction: nil
        )
        let mockStories = [dummyStory]
        
        // Act
        sut.updateMyStories(remaining: mockStories)
        
        // Assert
        XCTAssertEqual(sut.myStories.count, 1)
        XCTAssertEqual(sut.myStories.first?.id, "my_story_1")
    }
}
