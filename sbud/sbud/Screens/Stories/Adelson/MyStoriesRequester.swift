//
//  MyStoriesRequester.swift
//  sbud
//

import Foundation
import AdelsonAuthManager
import AdelsonApiCaller
internal import Alamofire

class MyStoriesRequester {

    func createApiCaller() -> AdelsonFirebaseApiCaller<StoriesFeedResponse> {
        return AdelsonFirebaseApiCaller<StoriesFeedResponse>()
    }

    func createEmptyApiCaller() -> AdelsonFirebaseApiCaller<EmptyResponse> {
        return AdelsonFirebaseApiCaller<EmptyResponse>()
    }

    func fetchMyStories(limit: Int = 20, offset: Int = 0) async throws -> StoriesFeedResponse {
        let apiCaller = createApiCaller()
        return try await apiCaller.callGet(
            url: "stories/my",
            queryParams: ["limit": String(limit), "offset": String(offset)],
            config: AdelsonFirebaseAuthConfig.shared
        )
    }

    func deleteStory(storyId: String) async throws {
        let apiCaller = createEmptyApiCaller()
        _ = try await apiCaller.call(
            url: "stories/\(storyId)",
            params: EmptyRequest(),
            method: .delete,
            config: AdelsonFirebaseAuthConfig.shared
        )
    }

    func deleteStoryImage(storyId: String, imageIndex: Int) async throws {
        let apiCaller = createEmptyApiCaller()
        _ = try await apiCaller.call(
            url: "stories/\(storyId)/images/\(imageIndex)",
            params: EmptyRequest(),
            method: .delete,
            config: AdelsonFirebaseAuthConfig.shared
        )
    }
}
