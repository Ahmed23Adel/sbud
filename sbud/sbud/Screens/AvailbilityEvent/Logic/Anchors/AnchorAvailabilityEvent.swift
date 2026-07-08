//
//  AnchorAvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

nonisolated class AnchorAvailabilityEvent: IAnchorAvailabilityEvent, CustomStringConvertible {
    
    nonisolated let id: String
    nonisolated var event: any IAvailabilityEvent
    nonisolated var eventId: String
    var description: String {
            "Id: \(id)"
    }

    

    init(eventId: String, event: any IAvailabilityEvent) {
        self.event = event
        self.id = event.id
        self.eventId = eventId
    }

    static func == (lhs: AnchorAvailabilityEvent, rhs: AnchorAvailabilityEvent) -> Bool {
        lhs.event.id == rhs.event.id
    }
}
