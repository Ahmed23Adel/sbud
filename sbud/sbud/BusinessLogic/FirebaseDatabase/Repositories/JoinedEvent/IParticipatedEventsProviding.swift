//
//  IParticipatedEventsProviding.swift
//  sbud
//

import Foundation

protocol IParticipatedEventsProviding {
    func fetchParticipated(for uid: String) async throws -> [JoinedEvent]
}

extension JoinedEventsRepository: IParticipatedEventsProviding {
    func fetchParticipated(for uid: String) async throws -> [JoinedEvent] {
        var query = initQueryBuilderObject()
        query = query.appendFilter(Filter(field: constants.userId, operation: .isEqualTo, value: uid))
        return try await fetch(query: query)
    }
}
