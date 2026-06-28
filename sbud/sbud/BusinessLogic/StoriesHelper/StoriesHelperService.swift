//
//  StoriesHelperService.swift
//  sbud
//

import Foundation
import FirebaseAuth

final class StoriesHelperService {

    static let shared = StoriesHelperService()
    private init() {}

    private let storiesRepo = StoriesRepository()

    func fetchFriendsWithStories() async throws -> [FriendWithStories] {
        let (friends, _) = try await fetchFriendsWithStoriesAndOwn()
        return friends
    }

    /// Returns friends' stories and the current user's own stories separately.
    func fetchFriendsWithStoriesAndOwn() async throws -> ([FriendWithStories], [Story]) {
        let currentUserId = Auth.auth().currentUser?.uid ?? ""

        let feed = try await storiesRepo.fetchFeed()

        var storiesByUser: [String: [Story]] = [:]
        for var story in feed.stories {
            story.myReaction = story.reactions[currentUserId]
            storiesByUser[story.userId, default: []].append(story)
        }

        let ownStories = storiesByUser.removeValue(forKey: currentUserId) ?? []

        let friends = storiesByUser
            .map { userId, stories -> FriendWithStories in
                let first = stories[0]
                return FriendWithStories(
                    id: userId,
                    name: first.authorName ?? userId,
                    profileImageUrl: first.authorProfileImageUrl,
                    stories: stories
                )
            }
            .sorted { $0.name < $1.name }

        return (friends, ownStories)
    }
}
