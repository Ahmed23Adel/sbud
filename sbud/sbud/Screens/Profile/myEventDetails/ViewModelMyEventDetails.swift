//
//  ViewModelMyEventDetails.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import OSLog
import FirebaseFirestore

@Observable
class ViewModelMyEventDetails{
    let logger = Logger(subsystem: "sBud", category: "ViewModelMyEventDetails")
    var myEventDertails: EventFullDetails? = nil
    var isLoading: Bool = false
    var eventId: String
    
    init(eventId: String){
        logger.info("eventId: \(eventId)")
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
    
    func confirmEventFinalChoice(selectedDateEntry: DateLocationEntry, selectedLocation: LocationPoint, finalStartDate: Date, finalEndDate: Date) async {
        await MainActor.run { isLoading = true }
        let db = Firestore.firestore()
        
        // Questo sarà il NUOVO array dateLocations. Sostituisce quello vecchio!
        let finalizedDateLocation: [[String: Any]] = [
            [
                "id": selectedDateEntry.id,
                // Usiamo le date decise con i DatePicker!
                "startDateTime": Timestamp(date: finalStartDate),
                "endDateTime": Timestamp(date: finalEndDate),
                "locations": [
                    [
                        "latitude": selectedLocation.latitude,
                        "longitude": selectedLocation.longitude,
                        "geohash": selectedLocation.geohash
                    ]
                ]
            ]
        ]
        
        do {
            try await db.collection("Events").document(eventId).updateData([
                "isDateConfirmed": true,
                "isLocationConfirmed": true,
                "status": "confirmed",
                "dateLocations": finalizedDateLocation // Sovrascrive le vecchie location
            ])
            
            // Ricaricando i dettagli, l'app riceverà una sola location e un solo range di date
            await loadDetails()
            await MainActor.run { isLoading = false }
            
        } catch {
            logger.error("Error confirming event: \(error.localizedDescription)")
            await MainActor.run { isLoading = false }
            PopUpGenerator.shared.show(msg: "Error confirming event", type: .error)
        }
    }
}
