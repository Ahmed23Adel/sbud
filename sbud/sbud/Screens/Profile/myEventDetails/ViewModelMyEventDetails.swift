//
//  ViewModelMyEventDetails.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import OSLog
import FirebaseFirestore

enum MyEventDetailsSheet: Identifiable {
    case confirmation
    case startSessionConfirmation

    var id: Self { self }
}

@Observable
class ViewModelMyEventDetails {
    let logger = Logger(subsystem: "sBud", category: "ViewModelMyEventDetails")

    var myEventDertails: EventFullDetails? = nil
    var isLoading: Bool = false
    var eventId: String

    var queueResponse: JoinQueueResponse? = nil
    var isLoadingQueue: Bool = false
    var showQueue: Bool = false

    private let joinRequester = JoinEventRequester()

    private var mainCoordinator: MainCoordinator?
    var activeSheet: MyEventDetailsSheet?
    
    
    var isSessionCreated = false
    
    init(eventId: String) {
        logger.info("eventId: \(eventId)")
        self.eventId = eventId
        Task { await loadDetails() }
        Task {
            do {
                isSessionCreated = try await isSessionCreated()
                logger.info("isSessionCreated \(self.isSessionCreated)")
            } catch {
                logger.fault("Error calling isSessionCreated \(error)")
            }
        }
    }

    func setMainCoordinator(mainCoordinator: MainCoordinator){
        self.mainCoordinator = mainCoordinator
    }
    private func loadDetails() async {
        await MainActor.run { isLoading = true }
        do {
            let requester = EventByIdRequester()
            let details = try await requester.fetchEvent(eventId: eventId)
            await MainActor.run {
                myEventDertails = details
                isLoading = false
            }
            await loadQueue()
            logger.log("Full event loaded \(self.eventId)")
        } catch {
            logger.error("Error: \(error)")
            await MainActor.run { isLoading = false }
            PopUpGenerator.shared.show(msg: "Error loading the event", type: .error)
        }
    }

    // MARK: - Queue

    func loadQueue() async {
        await MainActor.run { isLoadingQueue = true }
        do {
            let q = try await joinRequester.getPendingQueue(eventId: eventId)
            await MainActor.run {
                queueResponse = q
                isLoadingQueue = false
            }
        } catch {
            await MainActor.run { isLoadingQueue = false }
        }
    }

    func respondToRequest(requesterId: String, accept: Bool) async {
        do {
            _ = try await joinRequester.respondToRequest(
                eventId: eventId,
                requesterId: requesterId,
                accept: accept
            )
            await MainActor.run {
                if var q = queueResponse {
                    q.pendingUsers.removeAll { $0.userId == requesterId }
                    if accept { q.confirmedCount += 1 }
                    else { q.pendingCount = max(0, q.pendingCount - 1) }
                    q.isCapacityFull = (q.capacity != nil && q.confirmedCount >= q.capacity!)
                    queueResponse = q
                }
                let msg = accept ? "Confirmed" : "Rejected."
                PopUpGenerator.shared.show(msg: msg, type: accept ? .notification : .information)
            }
            await loadQueue()
        } catch {
            let msg = error.localizedDescription
            if msg.contains("full") {
                PopUpGenerator.shared.show(msg: "Capacity reached.", type: .warning)
            } else {
                PopUpGenerator.shared.show(msg: "Error: \(msg)", type: .error)
            }
            await loadQueue()
        }
    }

    // MARK: - Confirm Event

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
            "status": UsersEventStatus.confirmed.rawValue,
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
    
    
    func navigateToConfirmationForSessionOrNavigateToSessionDetails() {
        // TODO: Cache the results
        Task {
            if !isSessionCreated {
                activeSheet = .startSessionConfirmation
            } else {
                if let mainCoordinator {
                    mainCoordinator.navigateTo(.creatorSession(eventDetails: myEventDertails!, isSessionCreated: true))
                }
            }
            
        }
        
    }
    
    private func isSessionCreated() async throws -> Bool{
        let repo = OnGoingSessionRepository()
        var queryRef = repo.initQueryBuilderObject()
        queryRef = queryRef.appendFilter(Filter(field: repo.constants.eventId, operation: .isEqualTo, value: eventId))
        let sessions = try await repo.fetch(query: queryRef)
        logger.info("sessions count: \(sessions.count), \(sessions.count != 0)")
        return sessions.count != 0
            
    }
}
