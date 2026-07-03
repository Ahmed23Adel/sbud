//
//  ICreatedEventsProviding.swift
//  sbud
//

import Foundation

protocol ICreatedEventsProviding {
    func fetchCreated(for uid: String) async throws -> [UsersEvent]
}

extension UsersEventRepository: ICreatedEventsProviding {
    func fetchCreated(for uid: String) async throws -> [UsersEvent] {
        var query = initQueryBuilderObject()
        query = query.appendFilter(Filter(field: constants.creatorId, operation: .isEqualTo, value: uid))
        return try await fetch(query: query)
    }
}
