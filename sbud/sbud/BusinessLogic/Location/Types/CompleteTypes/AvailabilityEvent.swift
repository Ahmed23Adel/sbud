//
//  AvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation
import FirebaseFirestore
import Combine
import OSLog

class AvailabilityEvent: IAvailabilityEvent, ObservableObject {
    var id: String
    var eventId: String
    var geoPoint: GeoPoint
    let dateLocationId: String //
    let activityType: String //
    let startDateTime: Date //
    let endDateTime: Date //
    let createdAt: Date //
    let g: GeoLocation //
    let isDateConfirmed: Bool //
    let isLocationConfirmed: Bool //
    let isPublic: Bool //
    let eventImage: String //
    let creatorName: String
    let logger = Logger(subsystem: "sBud", category: "AvailabilityEvent")
    var fullDatailedEvent: EventFullDetails?
    @Published var isLoading: Bool = false
    

    init(
        id: String,
        eventId: String,
        geoPoint: GeoPoint,
        dateLocationId: String,
        activityType: String,
        startDateTime: Date,
        endDateTime: Date,
        createdAt: Date,
        g: GeoLocation,
        isDateConfirmed: Bool,
        isLocationConfirmed: Bool,
        isPublic: Bool,
        eventImage: String,
        creatorName: String
    ) {
        logger.info("id: \(id)")
        logger.info("eventId: \(eventId)")
        self.id = id
        self.geoPoint = geoPoint
        self.dateLocationId = dateLocationId
        self.activityType = activityType
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.createdAt = createdAt
        self.g = g
        self.isDateConfirmed = isDateConfirmed
        self.isLocationConfirmed = isLocationConfirmed
        self.isPublic = isPublic
        self.eventImage = eventImage
        self.creatorName = creatorName
        self.eventId = eventId
    }

       

    static func == (lhs: AvailabilityEvent, rhs: AvailabilityEvent) -> Bool {
        lhs.id == rhs.id
    }
    
    func loadRestOfDetails() async {
        isLoading = true
        do {
            
            let requester = EventByIdRequester()
            fullDatailedEvent = try await requester.fetchEvent(eventId: eventId)
            await MainActor.run {
                isLoading = false
            }
        } catch {
            logger.error("Error: \(error)")
            PopUpGenerator.shared.show(msg: "Error laoding the event", type: .error)
        }
        
    }
    
    func convertToAnchor() -> AnchorAvailabilityEvent{
        AnchorAvailabilityEvent(
            event: self)
    }

}
