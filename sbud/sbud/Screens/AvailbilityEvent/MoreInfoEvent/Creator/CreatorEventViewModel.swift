//
//  CreatorEventViewModel.swift
//  sbud
//
//  Created by Erdal on 07.05.2026.
//

import Foundation
import OSLog
import FirebaseFirestore

@Observable
class CreatorEventViewModel {
    let eventId: String
    let logger = Logger(subsystem: "sBud", category: "CreatorEventViewModel")

    var fullDetails: EventFullDetails? = nil
    var isLoading = false
    var isErrorLoading = false
    var queueResponse: JoinQueueResponse? = nil
    var isLoadingQueue = false
    var showQueue = false

    private let joinRequester = JoinEventRequester()

    init(eventId: String) {
        self.eventId = eventId
        Task { await loadDetails() }
    }

    func loadDetails() async {
        await MainActor.run { isLoading = true }
        do {
            let details = try await EventByIdRequester().fetchEvent(eventId: eventId)
            await MainActor.run { fullDetails = details; isLoading = false; isErrorLoading = false }
            await loadQueue()
        } catch {
            logger.error("loadDetails error: \(error)")
            await MainActor.run { isErrorLoading = true; isLoading = false }
            PopUpGenerator.shared.show(msg: "Error loading the event", type: .error)
        }
    }

    func loadQueue() async {
        await MainActor.run { isLoadingQueue = true }
        do {
            let q = try await joinRequester.getPendingQueue(eventId: eventId)
            await MainActor.run { queueResponse = q; isLoadingQueue = false }
        } catch {
            await MainActor.run { isLoadingQueue = false }
        }
    }

    func respondToRequest(requesterId: String, accept: Bool) async {
        do {
            _ = try await joinRequester.respondToRequest(eventId: eventId, requesterId: requesterId, accept: accept)
            await MainActor.run {
                if var q = queueResponse {
                    q.pendingUsers.removeAll { $0.userId == requesterId }
                    if accept { q.confirmedCount += 1 } else { q.pendingCount = max(0, q.pendingCount - 1) }
                    q.isCapacityFull = (q.capacity != nil && q.confirmedCount >= q.capacity!)
                    queueResponse = q
                }
                PopUpGenerator.shared.show(msg: accept ? "Confirmed" : "Rejected.", type: accept ? .notification : .information)
            }
            await loadQueue()
        } catch {
            let msg = error.localizedDescription
            PopUpGenerator.shared.show(msg: msg.contains("full") ? "Capacity reached." : "Error: \(msg)", type: .error)
            await loadQueue()
        }
    }

    func confirmEventFinalChoice(
        selectedDateEntry: DateLocationEntry,
        selectedLocation: LocationPoint,
        finalStartDate: Date,
        finalEndDate: Date
    ) async {
        await MainActor.run { isLoading = true }
        let db = Firestore.firestore()
        let batch = db.batch()
        let eventRef = db.collection("Events").document(eventId)

        let finalizedDateLocation: [[String: Any]] = [[
            "id": selectedDateEntry.id,
            "startDateTime": Timestamp(date: finalStartDate),
            "endDateTime": Timestamp(date: finalEndDate),
            "locations": [[
                "latitude": selectedLocation.latitude,
                "longitude": selectedLocation.longitude,
                "geohash": selectedLocation.geohash
            ]]
        ]]

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

                if docDateLocationId == selectedDateEntry.id && isChosenLocation {
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
            logger.error("Error confirming event: \(error.localizedDescription)")
            await MainActor.run { isLoading = false }
            PopUpGenerator.shared.show(msg: "Error confirming event", type: .error)
        }
    }
}
