//
//  MyStoryDocument.swift
//  sbud
//

import Foundation
import FirebaseFirestore

struct MyStoryDocument: Codable, Identifiable {
    @DocumentID var id: String?
    var storyId: String
    var userId: String
    var userName: String?
    var userAvatarUrl: String?
    var images: [String]
    var text: String?
    var reactions: [String: String]
    var activityType: String?
    var eventId: String?
    var eventName: String?
    var eventImage: String?
    var createdAt: String
    var expiresAt: String?
}
