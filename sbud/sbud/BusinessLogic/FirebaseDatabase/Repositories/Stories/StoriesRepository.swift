//
//  StoriesRepository.swift
//  sbud
//

import Foundation

final class StoriesRepository {

    private let baseURL = "https://sbud-backend.onrender.com/api/v1"

    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }

    private func authedRequest(url: URL, method: String) async throws -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        guard let token = try await BasicAuth.getTokenId() else {
            throw StoriesError.unauthenticated
        }
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return req
    }

    func fetchFeed(limit: Int = 20, offset: Int = 0) async throws -> StoriesFeedResponse {
        let url = URL(string: "\(baseURL)/stories/feed?limit=\(limit)&offset=\(offset)")!
        let req = try await authedRequest(url: url, method: "GET")
        let (data, _) = try await URLSession.shared.data(for: req)
        return try decoder.decode(StoriesFeedResponse.self, from: data)
    }

    func createStory(eventId: String?, text: String?, imageDataList: [Data]) async throws -> CreateStoryResponse {
        let url = URL(string: "\(baseURL)/stories")!
        var req = try await authedRequest(url: url, method: "POST")
        let boundary = UUID().uuidString
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.httpBody = buildMultipartBody(eventId: eventId, text: text, images: imageDataList, boundary: boundary)
        let (data, _) = try await URLSession.shared.data(for: req)
        return try decoder.decode(CreateStoryResponse.self, from: data)
    }

    func markImageViewed(storyId: String, imageIndex: Int) async throws {
        let url = URL(string: "\(baseURL)/stories/\(storyId)/view-image")!
        var req = try await authedRequest(url: url, method: "POST")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(["imageIndex": imageIndex])
        _ = try await URLSession.shared.data(for: req)
    }

    func react(storyId: String, emoji: String?) async throws -> [String: String] {
        let url = URL(string: "\(baseURL)/stories/\(storyId)/react")!
        var req = try await authedRequest(url: url, method: "POST")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        struct Body: Encodable { let emoji: String? }
        req.httpBody = try JSONEncoder().encode(Body(emoji: emoji))
        let (data, _) = try await URLSession.shared.data(for: req)
        struct ReactResponse: Decodable { let reactions: [String: String] }
        return (try? decoder.decode(ReactResponse.self, from: data))?.reactions ?? [:]
    }

    func deleteStory(_ storyId: String) async throws {
        let url = URL(string: "\(baseURL)/stories/\(storyId)")!
        let req = try await authedRequest(url: url, method: "DELETE")
        _ = try await URLSession.shared.data(for: req)
    }

    // MARK: - Multipart body builder

    private func buildMultipartBody(eventId: String?, text: String?, images: [Data], boundary: String) -> Data {
        var body = Data()
        if let eventId {
            body.appendFormField(name: "eventId", value: eventId, boundary: boundary)
        }
        if let text, !text.isEmpty {
            body.appendFormField(name: "text", value: text, boundary: boundary)
        }
        for (i, imageData) in images.enumerated() {
            body.appendFileField(
                name: "images",
                filename: "photo\(i).jpg",
                data: imageData,
                mimeType: "image/jpeg",
                boundary: boundary
            )
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

enum StoriesError: LocalizedError {
    case unauthenticated

    var errorDescription: String? {
        "You must be logged in to use stories."
    }
}

private extension Data {
    mutating func appendFormField(name: String, value: String, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }

    mutating func appendFileField(name: String, filename: String, data fileData: Data, mimeType: String, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        append(fileData)
        append("\r\n".data(using: .utf8)!)
    }
}
