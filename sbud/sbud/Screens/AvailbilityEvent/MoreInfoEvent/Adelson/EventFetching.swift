//
//  EventFetching.swift
//  sbud
//

import Foundation

protocol EventFetching {
    func fetchEvent(eventId: String) async throws -> EventFullDetails
}

extension EventByIdRequester: EventFetching {}
