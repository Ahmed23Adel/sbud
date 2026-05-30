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
        let currentUserId = Auth.auth().currentUser?.uid ?? ""

        let feed = try await storiesRepo.fetchFeed()

        // Inject myReaction from reactions dict, then group by userId
        var storiesByUser: [String: [Story]] = [:]
        for var story in feed.stories {
            story.myReaction = story.reactions[currentUserId]
            storiesByUser[story.userId, default: []].append(story)
        }

        // Build one FriendWithStories per user — author info comes from the story itself
        return storiesByUser
            .map { userId, stories -> FriendWithStories in
                let first = stories[0]
                let name = first.authorName ?? userId
                return FriendWithStories(
                    id: userId,
                    name: name,
                    profileImageUrl: first.authorProfileImageUrl,
                    stories: stories
                )
            }
            .sorted { $0.name < $1.name }
    }
}
