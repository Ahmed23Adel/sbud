//
//  StoriesHelperService.swift
//  sbud
//

import Foundation
import FirebaseAuth

final class StoriesHelperService {

    static let shared = StoriesHelperService()

    private let storiesRepo: any IStoriesRepository
    private let currentUserIdProvider: () -> String

    init(storiesRepo: any IStoriesRepository = StoriesRepository(),
         currentUserIdProvider: @escaping () -> String = { Auth.auth().currentUser?.uid ?? "" }) {
        self.storiesRepo = storiesRepo
        self.currentUserIdProvider = currentUserIdProvider
    }

    func fetchFriendsWithStories() async throws -> [FriendWithStories] {
        let (friends, _) = try await fetchFriendsWithStoriesAndOwn()
        return friends
    }

    /// Returns friends' stories and the current user's own stories separately.
    func fetchFriendsWithStoriesAndOwn() async throws -> ([FriendWithStories], [Story]) {
        let currentUserId = currentUserIdProvider()
        let feed = try await storiesRepo.fetchFeed(limit: 20, offset: 0)

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
