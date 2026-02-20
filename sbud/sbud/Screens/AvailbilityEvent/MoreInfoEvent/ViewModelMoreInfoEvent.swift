//
//  ViewModelMoreInfoEvent.swift
//  sbud
//
//  Created by ahmed on 02/02/2026.
//

import Foundation
import Combine
import OSLog

class ViewModelMoreInfoEvent: ObservableObject{
    let event: AvailabilityEvent
    let logger = Logger(subsystem: "sBud", category: "MoreInfo")
    
    init(event: AvailabilityEvent) {
        self.event = event
        logger.info("Selected activity: \(event.id)")
    }
    
    func loadRestOfDetails(){
        event.loadRestOfDetails()
    }
}
