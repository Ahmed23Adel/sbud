//
//  AnchorAvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

class AnchorAvailabilityEvent: IAnchorAvailabilityEvent{
    var availabilityEvent: any IAvailabilityEvent
    
    init(availabilityEvent: any IAvailabilityEvent) {
        self.availabilityEvent = availabilityEvent
    }
    
    static func == (lhs: AnchorAvailabilityEvent, rhs: AnchorAvailabilityEvent) -> Bool {
        lhs.availabilityEvent.id == rhs.availabilityEvent.id
    }
    
    
}
