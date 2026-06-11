//
//  StoriesRepository.swift
//  sbud
//

import Foundation

final class StoriesRepository: IStoriesRepository {

    private let baseURL: String
    private let session: URLSession
    private let tokenProvider: any IAuthTokenProvider
    private let decoder: JSONDecoder

    init(
        baseURL: String = "https://sbud-backend.onrender.com/api/v1",
        session: URLSession = .shared,
        tokenProvider: any IAuthTokenProvider = FirebaseAuthTokenProvider()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        d.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = d
    }

    func fetchFeed(limit: Int = 20, offset: Int = 0) async throws -> StoriesFeedResponse {
        let url = URL(string: "\(baseURL)/stories/feed?limit=\(limit)&offset=\(offset)")!
        let req = try await authedRequest(url: url, method: "GET")
        let (data, _) = try await session.data(for: req)
        return try decoder.decode(StoriesFeedResponse.self, from: data)
    }

    func createStory(eventId: String?, text: String?, imageDataList: [Data]) async throws -> CreateStoryResponse {
        let url = URL(string: "\(baseURL)/stories")!
        var req = try await authedRequest(url: url, method: "POST")
        let builder = MultipartBodyBuilder()
        req.setValue("multipart/form-data; boundary=\(builder.boundary)", forHTTPHeaderField: "Content-Type")
        req.httpBody = builder.build(eventId: eventId, text: text, images: imageDataList)
        let (data, _) = try await session.data(for: req)
        return try decoder.decode(CreateStoryResponse.self, from: data)
    }

    func markImageViewed(storyId: String, imageIndex: Int) async throws {
        let url = URL(string: "\(baseURL)/stories/\(storyId)/view-image")!
        var req = try await authedRequest(url: url, method: "POST")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(["imageIndex": imageIndex])
        _ = try await session.data(for: req)
    }

    func react(storyId: String, emoji: String?) async throws -> [String: String] {
        let url = URL(string: "\(baseURL)/stories/\(storyId)/react")!
        var req = try await authedRequest(url: url, method: "POST")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        struct Body: Encodable { let emoji: String? }
        req.httpBody = try JSONEncoder().encode(Body(emoji: emoji))
        let (data, _) = try await session.data(for: req)
        struct ReactResponse: Decodable { let reactions: [String: String] }
        return (try? decoder.decode(ReactResponse.self, from: data))?.reactions ?? [:]
    }

    func deleteStory(_ storyId: String) async throws {
        let url = URL(string: "\(baseURL)/stories/\(storyId)")!
        let req = try await authedRequest(url: url, method: "DELETE")
        _ = try await session.data(for: req)
    }

    // MARK: - Private

    private func authedRequest(url: URL, method: String) async throws -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        let token = try await tokenProvider.getToken()
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return req
    }
}

enum StoriesError: LocalizedError {
    case unauthenticated

    var errorDescription: String? {
        "You must be logged in to use stories."
    }
}
