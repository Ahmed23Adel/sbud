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
        let db = Firestore.firestore()
        let batch = db.batch()
        let formatter = ISO8601DateFormatter()

        let eventRef = db.collection("Events").document(eventId)

        let dateLocationData: [[String: Any]] = eventBuilder.dateLocationsHolder.lst.map { dl in
            [
                "id": UUID().uuidString,
                "startDateTime": formatter.string(from: dl.startDateTime),
                "endDateTime":   formatter.string(from: dl.endDateTime),
                "locations": dl.locations.map { geo in
                    ["latitude": geo.latitude, "longitude": geo.longitude]
                }
            ]
        }

        batch.updateData([
            "title":            eventBuilder.title,
            "notes":            eventBuilder.description,
            "eventImage":       eventBuilder.coverImgURL,
            "isPublic":         eventBuilder.isEventPublic,
            "joiningCondition": eventBuilder.joiningCondition.rawValue,
            "maxAllowedToJoin": eventBuilder.eventCapacity,
            "dateLocations":    dateLocationData
        ], forDocument: eventRef)

        do {

            let flattenedSnapshot = try await db.collection("flattenedEvents")
                .whereField("eventId", isEqualTo: eventId)
                .getDocuments()

            let sharedFlattenedUpdate: [String: Any] = [
                "activityType": eventBuilder.activityType.rawValue,
                "isPublic":     eventBuilder.isEventPublic,
                "eventImage":   eventBuilder.coverImgURL
            ]

            let newDateLocations = eventBuilder.dateLocationsHolder.lst

            if newDateLocations.isEmpty {
                for doc in flattenedSnapshot.documents {
                    batch.updateData(sharedFlattenedUpdate, forDocument: doc.reference)
                }
            } else {
                for doc in flattenedSnapshot.documents {
                    batch.deleteDocument(doc.reference)
                }
                for dl in newDateLocations {
                    for geo in dl.locations {
                        let newRef = db.collection("flattenedEvents").document()
                        var data: [String: Any] = sharedFlattenedUpdate
                        data["eventId"]             = eventId
                        data["startDateTime"]       = formatter.string(from: dl.startDateTime)
                        data["endDateTime"]         = formatter.string(from: dl.endDateTime)
                        data["isDateConfirmed"]     = false
                        data["isLocationConfirmed"] = false
                        data["geoPoint"]            = GeoPoint(latitude: geo.latitude, longitude: geo.longitude)
                        batch.setData(data, forDocument: newRef)
                    }
                }
            }

            let joinedSnapshot = try await db.collection("joinedEvents")
                .whereField("eventId", isEqualTo: eventId)
                .getDocuments()

            let joinedUpdate: [String: Any] = [
                "title":        eventBuilder.title,
                "eventImage":   eventBuilder.coverImgURL,
                "activityType": eventBuilder.activityType.rawValue
            ]

            for doc in joinedSnapshot.documents {
                batch.updateData(joinedUpdate, forDocument: doc.reference)
            }

            try await batch.commit()

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
