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

@Observable
class AvailabilityEvent: IAvailabilityEvent, CustomStringConvertible {
    var id: String
    var eventId: String
    var geoPoint: GeoPoint
    let dateLocationId: String
    let activityType: String
    let startDateTime: Date
    let endDateTime: Date
    let createdAt: Date
    let g: GeoLocation
    let isDateConfirmed: Bool
    let isLocationConfirmed: Bool
    let isPublic: Bool //
    let eventImage: String
    let creatorName: String
    let logger = Logger(subsystem: "sBud", category: "AvailabilityEvent")
    var fullDatailedEvent: EventFullDetails?
    var isLoading: Bool = false
    
    let creatorUserId: String?
    //@Published var isLoad: Bool = false
    

    var description: String {
        """
        AvailabilityEvent(
            id: \(id),
            eventId: \(eventId),
            geoPoint: \(geoPoint),
            dateLocationId: \(dateLocationId),
            activityType: \(activityType),
            startDateTime: \(startDateTime),
            endDateTime: \(endDateTime),
            createdAt: \(createdAt),
            g: \(g),
            isDateConfirmed: \(isDateConfirmed),
            isLocationConfirmed: \(isLocationConfirmed),
            isPublic: \(isPublic),
            eventImage: \(eventImage),
            creatorName: \(creatorName),
            isLoading: \(isLoading)
        )
        """
    }
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
        creatorName: String,
        creatorUserId: String
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
        self.creatorUserId = creatorUserId
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
        AnchorAvailabilityEvent(eventId: self.eventId, event: self)
    }

}

// AvailabilityEvent+Preview.swift

#if DEBUG
extension AvailabilityEvent {
    static var preview: AvailabilityEvent {
        let event = AvailabilityEvent(
            id: "cf5f3e6b-a62b-4c43-85f5-e47ca287419f",
            eventId: "xN6ncT0Foa0UdFy06GSL",
            geoPoint: GeoPoint(latitude: 45.4642, longitude: 9.1900),
            dateLocationId: "milano_centro_001",
            activityType: "Running",
            startDateTime: Date().addingTimeInterval(3600),
            endDateTime: Date().addingTimeInterval(7200),
            createdAt: Date(),
            g: GeoLocation(geopoint: Coordinate(latitude: 43, longitude: 9.4), geohash: "u0ndx37j"),
            isDateConfirmed: true,
            isLocationConfirmed: false,
            isPublic: true,
            eventImage: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s",
            creatorName: "ahmed",
            creatorUserId: ""
        )
        event.fullDatailedEvent = .sample
        return event
    }
}
#endif
