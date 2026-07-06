//
//  MockStoriesRepository.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 06/07/2026.
//


import Foundation
@testable import sbud

final class MockStoriesRepository: IStoriesRepository {
    var feedToReturn: StoriesFeedResponse?
    var createStoryCalled = false
    var receivedEventId: String?
    var receivedText: String?
    var receivedImageCount = 0
    var shouldThrow = false
    var markedViewed: [(storyId: String, imageIndex: Int)] = []
    var deletedStories: [String] = []
    var deletedImages: [(storyId: String, imageIndex: Int)] = []

    func createStory(eventId: String?, text: String?, imageDataList: [Data]) async throws -> CreateStoryResponse {
        createStoryCalled = true
        receivedEventId = eventId
        receivedText = text
        receivedImageCount = imageDataList.count
        if shouldThrow { throw NSError(domain: "test", code: 1) }
        return CreateStoryResponse(id: "new_story_id")
    }

    func markImageViewed(storyId: String, imageIndex: Int) async throws {
        markedViewed.append((storyId, imageIndex))
    }

    func deleteStory(_ storyId: String) async throws {
        if shouldThrow { throw NSError(domain: "test", code: 1) }
        deletedStories.append(storyId)
    }

    func deleteStoryImage(storyId: String, imageIndex: Int) async throws {
        if shouldThrow { throw NSError(domain: "test", code: 1) }
        deletedImages.append((storyId, imageIndex))
    }

    func react(storyId: String, emoji: String?) async throws -> [String: String] {
        [:]
    }

    func fetchFeed(limit: Int, offset: Int) async throws -> StoriesFeedResponse {
        if shouldThrow { throw NSError(domain: "test", code: 1) }
        if let feedToReturn { return feedToReturn }
        throw NSError(domain: "unused", code: 0)
    }

    func fetchMyStories(limit: Int, offset: Int) async throws -> StoriesFeedResponse {
        throw NSError(domain: "unused", code: 0)
    }
}
