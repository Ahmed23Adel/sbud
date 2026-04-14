//
//  AnchorAvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

nonisolated class AnchorAvailabilityEvent: IAnchorAvailabilityEvent {
    nonisolated let id: String
    nonisolated var event: any IAvailabilityEvent

    init(event: any IAvailabilityEvent) {
        self.event = event
        self.id = event.id
    }

    static func == (lhs: AnchorAvailabilityEvent, rhs: AnchorAvailabilityEvent) -> Bool {
        lhs.event.id == rhs.event.id
    }
}
