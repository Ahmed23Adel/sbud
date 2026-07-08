//
//  ViewModelMyEventEdit.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import Foundation
import FirebaseFirestore
import OSLog

@Observable
class ViewModelMyEventEdit {
    let logger = Logger(subsystem: "sBud", category: "ViewModelMyEventEdit")

    var eventBuilder: NewEventBuilder
    let eventId: String

    var isLoading = false
    var didSave = false

    private let updateRequester = UpdateEventRequester()

    init(event: EventFullDetails) {
        self.eventId = event.id

        let builder = NewEventBuilder()
        builder.title             = event.title
        builder.description       = event.notes ?? ""
        builder.coverImgURL       = event.eventImage ?? ""
        builder.activityExtraArgs = event.activityDetails
        builder.activityType      = event.activityType
        builder.isEventPublic     = event.isPublic
        builder.joiningCondition  = event.joinCondition
        builder.eventCapacity     = event.maxAllowedToJoin ?? 150

        let dateLocationsHolder = MultipleDateLocationsHolder()
        for entry in event.dateLocations {
            for loc in entry.locations {
                let geoPoint = GeoPoint(latitude: loc.latitude, longitude: loc.longitude)
                let dl = DateLocations(
                    startDateTime: entry.startDateTime,
                    endDateTime:   entry.endDateTime,
                    locations:     [geoPoint]
                )
                dateLocationsHolder.lst.append(dl)
            }
        }
        builder.dateLocationsHolder = dateLocationsHolder

        self.eventBuilder = builder
    }

    func saveChanges() {
        guard eventBuilder.areFieldsValid() else {
            eventBuilder.generateErrorMsg()
            return
        }
        Task { await _save() }
    }

    private func _save() async {
        await MainActor.run { isLoading = true }

        let request = UpdateEventRequest(
            activityDetails:  eventBuilder.activityExtraArgs.extraArgs,
            title:            eventBuilder.title,
            eventImage:       eventBuilder.coverImgURL,
            isPublic:         eventBuilder.isEventPublic,
            joiningCondition: eventBuilder.joiningCondition,
            maxAllowedToJoin: eventBuilder.eventCapacity,
            notes:            eventBuilder.description,
            dateLocations:    eventBuilder.dateLocationsHolder.lst
        )

        do {
            try await updateRequester.updateEvent(eventId: eventId, requestParams: request)
            await MainActor.run {
                isLoading = false
                didSave   = true
            }
            PopUpGenerator.shared.show(msg: "Event updated successfully", type: .notification)
        } catch {
            logger.error("Error updating event: \(error.localizedDescription)")
            await MainActor.run { isLoading = false }
            PopUpGenerator.shared.show(msg: "Error saving changes", type: .error)
        }
    }
}
