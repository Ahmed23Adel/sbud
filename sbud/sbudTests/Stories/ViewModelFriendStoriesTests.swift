//
//  ViewModelFriendStoriesTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 06/07/2026.
//


import XCTest
@testable import sbud

@MainActor
final class ViewModelFriendStoriesTests: XCTestCase {

    private var repo: MockStoriesRepository!

    override func setUp() {
        super.setUp()
        repo = MockStoriesRepository()
    }

    private func makeStory(id: String, imageCount: Int) -> Story {
        let images = (0..<imageCount).map { StoryImage(index: $0, url: "") }
        return Story(
            id: id, userId: "user_1", authorName: nil, authorProfileImageUrl: nil,
            eventId: nil, eventName: nil, eventImage: nil, activityType: nil,
            images: images, text: nil, reactions: [:], createdAt: Date(),
            expiresAt: nil, myReaction: nil
        )
    }

    private func makeSUT(_ stories: [Story], onChange: (([Story]) -> Void)? = nil) -> ViewModelFriendStories {
        ViewModelFriendStories(stories: stories, storiesRepo: repo, onStoriesChanged: onChange)
    }

    // MARK: Stato iniziale

    func test_initialState_pointsToFirstStoryFirstImage() {
        let sut = makeSUT([makeStory(id: "s1", imageCount: 2)])
        XCTAssertEqual(sut.currentStory?.id, "s1")
        XCTAssertEqual(sut.currentImage?.index, 0)
    }

    func test_isAtEnd_trueWhenNoStories() {
        let sut = makeSUT([])
        XCTAssertTrue(sut.isAtEnd)
    }

    func test_isAtEnd_trueOnLastImageOfLastStory() {
        let sut = makeSUT([makeStory(id: "s1", imageCount: 1)])
        XCTAssertTrue(sut.isAtEnd)
    }

    // MARK: advanceMarkingViewed

    func test_advance_removesImageAndStaysOnSameStory() async {
        let sut = makeSUT([makeStory(id: "s1", imageCount: 3)])

        await sut.advanceMarkingViewed()

        XCTAssertEqual(sut.currentStory?.id, "s1")
        XCTAssertEqual(sut.stories[0].images.count, 2)
        XCTAssertEqual(sut.currentImage?.index, 1, "Dopo la rimozione deve puntare all'immagine successiva")
    }

    func test_advance_lastImageOfStory_removesStoryAndMovesToNext() async {
        let sut = makeSUT([makeStory(id: "s1", imageCount: 1),
                           makeStory(id: "s2", imageCount: 1)])

        await sut.advanceMarkingViewed()

        XCTAssertEqual(sut.stories.count, 1)
        XCTAssertEqual(sut.currentStory?.id, "s2")
        XCTAssertEqual(sut.currentImageIndex, 0)
    }

    func test_advance_lastImageOfLastStory_leavesEmptyList() async {
        let sut = makeSUT([makeStory(id: "s1", imageCount: 1)])

        await sut.advanceMarkingViewed()

        XCTAssertTrue(sut.stories.isEmpty)
    }

    func test_advance_notifiesOnStoriesChanged() async {
        var received: [Story]?
        let sut = makeSUT([makeStory(id: "s1", imageCount: 1)]) { received = $0 }

        await sut.advanceMarkingViewed()

        XCTAssertNotNil(received)
        XCTAssertTrue(received!.isEmpty)
    }

    // MARK: goBackImage

    func test_goBackImage_decrementsImageIndex() {
        let sut = makeSUT([makeStory(id: "s1", imageCount: 3)])
        sut.currentImageIndex = 2

        sut.goBackImage()

        XCTAssertEqual(sut.currentImageIndex, 1)
    }

    func test_goBackImage_onFirstImage_goesToPreviousStoryLastImage() {
        let sut = makeSUT([makeStory(id: "s1", imageCount: 3),
                           makeStory(id: "s2", imageCount: 2)])
        sut.currentStoryIndex = 1
        sut.currentImageIndex = 0

        sut.goBackImage()

        XCTAssertEqual(sut.currentStoryIndex, 0)
        XCTAssertEqual(sut.currentImageIndex, 2, "Deve andare all'ultima immagine della storia precedente")
    }

    func test_goBackImage_atVeryStart_doesNothing() {
        let sut = makeSUT([makeStory(id: "s1", imageCount: 2)])

        sut.goBackImage()

        XCTAssertEqual(sut.currentStoryIndex, 0)
        XCTAssertEqual(sut.currentImageIndex, 0)
    }

    // MARK: delete

    func test_deleteCurrentStory_removesStoryAndCallsRepo() async {
        let sut = makeSUT([makeStory(id: "s1", imageCount: 2),
                           makeStory(id: "s2", imageCount: 1)])
        var deletedCallbackFired = false

        await sut.deleteCurrentStory { deletedCallbackFired = true }

        XCTAssertEqual(repo.deletedStories, ["s1"])
        XCTAssertEqual(sut.stories.count, 1)
        XCTAssertFalse(deletedCallbackFired, "Il callback scatta solo se non restano storie")
    }

    func test_deleteCurrentImage_lastImage_deletesWholeStory() async {
        let sut = makeSUT([makeStory(id: "s1", imageCount: 1)])
        var lastDeleted = false

        await sut.deleteCurrentImage { lastDeleted = true }

        XCTAssertEqual(repo.deletedStories, ["s1"])
        XCTAssertTrue(sut.stories.isEmpty)
        XCTAssertTrue(lastDeleted)
    }
}