//
//  Story.swift
//  sbud
//

import Foundation

nonisolated struct StoryImage: Equatable, Hashable, Sendable {
    let index: Int
    let url: String
}

nonisolated struct Story: Decodable, Identifiable, Equatable, Hashable, Sendable {
    let id: String               // "storyId" on the wire
    let userId: String
    let authorName: String?      // "userName"
    let authorProfileImageUrl: String? // "userAvatarUrl"
    let eventId: String?
    let eventName: String?
    let eventImage: String?
    let activityType: String?
    var images: [StoryImage]     // server sends [String], decoded below
    var text: String?
    let reactions: [String: String] // userId → emoji
    let createdAt: Date
    let expiresAt: Date?
    var myReaction: String?      // populated client-side from reactions[currentUserId]

    // MARK: - Manual init (used for local reaction mutations)

    init(
        id: String, userId: String, authorName: String?, authorProfileImageUrl: String?,
        eventId: String?, eventName: String?, eventImage: String?, activityType: String?,
        images: [StoryImage], text: String?, reactions: [String: String],
        createdAt: Date, expiresAt: Date?, myReaction: String?
    ) {
        self.id = id; self.userId = userId
        self.authorName = authorName; self.authorProfileImageUrl = authorProfileImageUrl
        self.eventId = eventId; self.eventName = eventName
        self.eventImage = eventImage; self.activityType = activityType
        self.images = images; self.text = text; self.reactions = reactions
        self.createdAt = createdAt; self.expiresAt = expiresAt
        self.myReaction = myReaction
    }

    // MARK: - Decoding

    private enum CodingKeys: String, CodingKey {
        case id = "storyId"
        case userId
        case authorName = "userName"
        case authorProfileImageUrl = "userAvatarUrl"
        case eventId, eventName, eventImage, activityType
        case images, text, reactions, createdAt, expiresAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                    = try c.decode(String.self,   forKey: .id)
        userId                = try c.decode(String.self,   forKey: .userId)
        authorName            = try c.decodeIfPresent(String.self, forKey: .authorName)
        authorProfileImageUrl = try c.decodeIfPresent(String.self, forKey: .authorProfileImageUrl)
        eventId               = try c.decodeIfPresent(String.self, forKey: .eventId)
        eventName             = try c.decodeIfPresent(String.self, forKey: .eventName)
        eventImage            = try c.decodeIfPresent(String.self, forKey: .eventImage)
        activityType          = try c.decodeIfPresent(String.self, forKey: .activityType)
        text                  = try c.decodeIfPresent(String.self, forKey: .text)
        reactions             = (try? c.decode([String: String].self, forKey: .reactions)) ?? [:]
        createdAt             = try c.decode(Date.self, forKey: .createdAt)
        expiresAt             = try? c.decode(Date.self, forKey: .expiresAt)

        // Server sends images as [String] URLs — convert to indexed StoryImage
        let urls  = try c.decode([String].self, forKey: .images)
        images    = urls.enumerated().map { StoryImage(index: $0.offset, url: $0.element) }

        myReaction = nil // set by StoriesHelperService after decoding
    }
}

nonisolated struct StoriesFeedResponse: Decodable, Sendable {
    let stories: [Story]
    let total: Int
    let hasMore: Bool
}

nonisolated struct CreateStoryResponse: Decodable, Sendable {
    let id: String

    private enum CodingKeys: String, CodingKey {
        case id = "storyId"
    }
}

nonisolated struct FriendWithStories: Identifiable, Sendable {
    let id: String
    let name: String
    let profileImageUrl: String?
    let stories: [Story]
}
