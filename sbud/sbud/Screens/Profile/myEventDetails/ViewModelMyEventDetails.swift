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
        
        
        let batch = db.batch()
        
        
        let eventRef = db.collection("Events").document(eventId)
        let finalizedDateLocation: [[String: Any]] = [
            [
                "id": selectedDateEntry.id,
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
        
        batch.updateData([
            "isDateConfirmed": true,
            "isLocationConfirmed": true,
            "status": "confirmed",
            "dateLocations": finalizedDateLocation
        ], forDocument: eventRef)
        
        do {
            
            let flattenedSnapshot = try await db.collection("flattenedEvents")
                .whereField("eventId", isEqualTo: eventId)
                .getDocuments()
            
            
            for doc in flattenedSnapshot.documents {
                let data = doc.data()
                
                let docDateLocationId = data["dateLocationId"] as? String ?? ""
                var isChosenLocation = false
                
                
                if let geoPoint = data["geoPoint"] as? GeoPoint {
                    
                    let latDiff = abs(geoPoint.latitude - selectedLocation.latitude)
                    let lonDiff = abs(geoPoint.longitude - selectedLocation.longitude)
                    isChosenLocation = (latDiff < 0.00001 && lonDiff < 0.00001)
                } else if let g = data["g"] as? [String: Any], let geohash = g["geohash"] as? String {
                    
                    isChosenLocation = (geohash == selectedLocation.geohash)
                }
                
                
                let isChosenEntry = (docDateLocationId == selectedDateEntry.id)
                
                if isChosenEntry && isChosenLocation {
                    
                    batch.updateData([
                        "startDateTime": Timestamp(date: finalStartDate),
                        "endDateTime": Timestamp(date: finalEndDate),
                        "isDateConfirmed": true,
                        "isLocationConfirmed": true
                    ], forDocument: doc.reference)
                } else {
                   
                    batch.deleteDocument(doc.reference)
                }
            }
            
            
            try await batch.commit()
            
            
            await loadDetails()
            await MainActor.run { isLoading = false }
            
        } catch {
            logger.error("Error confirming event & deleting flattened locations: \(error.localizedDescription)")
            await MainActor.run { isLoading = false }
            PopUpGenerator.shared.show(msg: "Error confirming event", type: .error)
        }
    }
}
