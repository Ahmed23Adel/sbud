//
//  ViewModelMyEventDetails.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import OSLog

@Observable
class ViewModelMyEventDetails{
    let logger = Logger(subsystem: "sBud", category: "ViewModelMyEventDetails")
    var myEventDertails: EventFullDetails? = nil
    var isLoading: Bool = false
    var eventId: String
    
    init(eventId: String){
        self.eventId = eventId
        Task {
            await loadDetails()
        }
        
    }
    
    private func loadDetails() async {
        await MainActor.run { isLoading = true }
        do {
            let requester = EventByIdRequester()
            myEventDertails = try await requester.fetchEvent(eventId: eventId)
            await MainActor.run {
                isLoading = false
            }
            logger.log("Full event loaded \(self.eventId)")
        } catch {
            logger.error("Error: \(error)")
            await MainActor.run {
                isLoading = false
            }
            PopUpGenerator.shared.show(msg: "Error loading the event", type: .error)
        }
    }
}
