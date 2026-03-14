//
//  CreateNewEventResponse.swift
//  sbud
//
//  Created by ahmed on 11/03/2026.
//

import Foundation

nonisolated struct FlattenedEvent: Decodable, Sendable{
    var flattenedEventId: String
    var dateLocationId: String
}
nonisolated struct CreateNewEventResponse: Decodable, Sendable{
    var eventId: String
    var flattenedEvents: [FlattenedEvent]
    var message: String
}
