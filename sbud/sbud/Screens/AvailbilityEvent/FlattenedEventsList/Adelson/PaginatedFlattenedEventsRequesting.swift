//
//  PaginatedFlattenedEventsRequesting.swift
//  sbud
//

import Foundation

protocol PaginatedFlattenedEventsRequesting {
    func fetchEvents(requestParams: PaginatedFlattenedEventsRequest) async throws -> PaginatedEventDetailsResponse
}

extension PaginatedFlattenedEventsRequester: PaginatedFlattenedEventsRequesting {}
