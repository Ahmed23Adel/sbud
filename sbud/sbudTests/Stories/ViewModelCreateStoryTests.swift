//
//  ViewModelCreateStoryTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 06/07/2026.
//


import XCTest
import UIKit
@testable import sbud

@MainActor
final class ViewModelCreateStoryTests: XCTestCase {

    private var repo: MockStoriesRepository!
    private var sut: ViewModelCreateStory!

    override func setUp() {
        super.setUp()
        repo = MockStoriesRepository()
        sut = ViewModelCreateStory(storiesRepo: repo)
    }

    override func tearDown() {
        sut = nil
        repo = nil
        super.tearDown()
    }

    private func makeImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }

    private func makeEvent() -> ViewModelCreateStory.EventSummary {
        .init(id: "ev1", title: "Padel", imageUrl: "", activityType: .tennis)
    }

    // MARK: canPost

    func test_canPost_falseWhenNoImages() {
        sut.selectedEvent = makeEvent()
        XCTAssertFalse(sut.canPost)
    }

    func test_canPost_falseWhenNoEventSelected() {
        sut.selectedImages = [makeImage()]
        XCTAssertFalse(sut.canPost)
    }

    func test_canPost_trueWhenImagesAndEvent() {
        sut.selectedImages = [makeImage()]
        sut.selectedEvent = makeEvent()
        XCTAssertTrue(sut.canPost)
    }

    // MARK: post

    func test_post_blockedWhenCanPostIsFalse_doesNotCallRepo() async {
        await sut.post()
        XCTAssertFalse(repo.createStoryCalled)
    }

    func test_post_success_sendsDataAndSetsDidPost() async {
        sut.selectedImages = [makeImage(), makeImage()]
        sut.selectedEvent = makeEvent()
        sut.caption = "  bella storia  "

        await sut.post()

        XCTAssertTrue(repo.createStoryCalled)
        XCTAssertEqual(repo.receivedEventId, "ev1")
        XCTAssertEqual(repo.receivedText, "bella storia", "La caption deve essere trimmata")
        XCTAssertEqual(repo.receivedImageCount, 2)
        XCTAssertTrue(sut.didPost)
        XCTAssertFalse(sut.isPosting)
    }

    func test_post_emptyCaption_sendsNilText() async {
        sut.selectedImages = [makeImage()]
        sut.selectedEvent = makeEvent()
        sut.caption = "   "

        await sut.post()

        XCTAssertNil(repo.receivedText)
    }

    func test_post_repoThrows_didPostStaysFalse() async {
        sut.selectedImages = [makeImage()]
        sut.selectedEvent = makeEvent()
        repo.shouldThrow = true

        await sut.post()

        XCTAssertFalse(sut.didPost)
        XCTAssertFalse(sut.isPosting)
    }
}
