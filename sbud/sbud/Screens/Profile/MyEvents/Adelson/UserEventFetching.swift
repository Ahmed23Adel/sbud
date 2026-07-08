//
//  UserEventFetching.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import Foundation
protocol UsersEventFetching {
    func fetchCreatedEvents(userId: String) async throws -> [UsersEvent]
}
final class DefaultUsersEventFetcher: UsersEventFetching {
    private let repo = UsersEventRepository()
    func fetchCreatedEvents(userId: String) async throws -> [UsersEvent] {
        var query = repo.initQueryBuilderObject()
        query = query.appendFilter(Filter(field: repo.constants.creatorId, operation: .isEqualTo, value: userId))
        return try await repo.fetch(query: query)
    }
}
