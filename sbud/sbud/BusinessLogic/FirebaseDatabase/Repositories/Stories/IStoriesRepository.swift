//
//  IStoriesRepository.swift
//  sbud
//

import Foundation

protocol IStoriesRepository {
    func fetchFeed(limit: Int, offset: Int) async throws -> StoriesFeedResponse
    func createStory(eventId: String?, text: String?, imageDataList: [Data]) async throws -> CreateStoryResponse
    func markImageViewed(storyId: String, imageIndex: Int) async throws
    func react(storyId: String, emoji: String?) async throws -> [String: String]
    func deleteStory(_ storyId: String) async throws
}
