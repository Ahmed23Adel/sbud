//
//  ViewModelMyEventDetails.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation
import OSLog
import FirebaseFirestore
import FirebaseAnalytics

enum MyEventDetailsSheet: Identifiable {
    case confirmation, startSessionConfirmation
    var id: Self { self }
}

@Observable
class ViewModelMyEventDetails {
    let logger = Logger(subsystem: "sBud", category: "ViewModelMyEventDetails")

    var myEventDertails: EventFullDetails? = nil
    var isLoading: Bool = false
    var eventId: String
    var role: EventUserRole? = nil
    var queueResponse: JoinQueueResponse? = nil
    var isLoadingQueue: Bool = false
    var showQueue: Bool = false
    var activeSheet: MyEventDetailsSheet?
    var isSessionCreated = false
    var showDeleteConfirmation = false
    var isDeletingEvent = false
    var eventDeleted = false
    var showEditEvent = false
    var confirmedParticipants: [UserProfile] = []
    var isLoadingParticipants = false

    private let eventFetcher: EventFetching
    private let joinRequester: JoinEventRequesting
    private let deleteRequester: EventDeleting
    private var mainCoordinator: MainCoordinator?

    init(
        eventId: String,
        eventFetcher: EventFetching = EventByIdRequester(),
        joinRequester: JoinEventRequesting = JoinEventRequester(),
        deleteRequester: EventDeleting = DeleteEventRequester(),
        autoStart: Bool = true
    ) {
        self.eventId = eventId
        self.eventFetcher = eventFetcher
        self.joinRequester = joinRequester
        self.deleteRequester = deleteRequester
        logger.info("eventId: \(eventId)")
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "MyEventDetails", "event_id": eventId
        ])
        guard autoStart else { return }
        Task { await loadDetails() }
        Task {
            do { isSessionCreated = try await checkIsSessionCreated() } catch {
                logger.fault("Error calling isSessionCreated \(error)")
            }
        }
    }

    func setMainCoordinator(mainCoordinator: MainCoordinator) { self.mainCoordinator = mainCoordinator }

    func refresh() async {
        await loadDetails()
        do { isSessionCreated = try await checkIsSessionCreated() } catch {
            logger.fault("Error refreshing session status: \(error)")
        }
    }

    func loadDetails() async {
        isLoading = true
        do {
            async let detailsTask = eventFetcher.fetchEvent(eventId: eventId)
            async let roleTask    = EventRoleService.getRole(eventId: eventId)
            var (details, resolvedRole) = try await (detailsTask, roleTask)

            if details.isDateConfirmed && details.isLocationConfirmed {
                // Once confirmed, there must be exactly one date entry with exactly one location.
                if var confirmedEntry = details.dateLocations.first {
                    if let confirmedLocation = confirmedEntry.locations.first {
                        confirmedEntry.locations = [confirmedLocation]
                    }
                    details.dateLocations = [confirmedEntry]
                }
            } else {
                // Not confirmed yet: drop any duplicate IDs the database produced.
                var uniqueLocations: [DateLocationEntry] = []
                var seenIds = Set<String>()
                for loc in details.dateLocations {
                    if !seenIds.contains(loc.id) {
                        uniqueLocations.append(loc)
                        seenIds.insert(loc.id)
                    }
                }
                details.dateLocations = uniqueLocations
            }

            myEventDertails = details
            role = resolvedRole
            isLoading = false
            await loadQueue()
            await fetchParticipants()
        } catch {
            logger.error("Error: \(error)")
            isLoading = false
            PopUpGenerator.shared.show(msg: "Error loading the event", type: .error)
        }
    }

    private func fetchParticipants() async {
        isLoadingParticipants = true
        confirmedParticipants = await JoinedEventsRepository().fetchParticipants(eventId: eventId)
        isLoadingParticipants = false
    }

    func loadQueue() async {
        isLoadingQueue = true
        do { queueResponse = try await joinRequester.getPendingQueue(eventId: eventId) } catch {}
        isLoadingQueue = false
    }

    func respondToRequest(requesterId: String, accept: Bool) async {
        do {
            _ = try await joinRequester.respondToRequest(eventId: eventId, requesterId: requesterId, accept: accept)
            if var q = queueResponse {
                q.pendingUsers.removeAll { $0.userId == requesterId }
                if accept { q.confirmedCount += 1 } else { q.pendingCount = max(0, q.pendingCount - 1) }
                q.isCapacityFull = (q.capacity != nil && q.confirmedCount >= q.capacity!)
                queueResponse = q
            }
            PopUpGenerator.shared.show(msg: accept ? "Confirmed" : "Rejected.", type: accept ? .notification : .information)
            if let creatorId = myEventDertails?.creator.id {
                do {
                    try await NotificationsRepository().decrementPendingRequests(eventId: eventId, creatorUserId: creatorId)
                } catch {
                    logger.error("Error decrementing pending requests count: \(error.localizedDescription)")
                }
            }
            await loadQueue()
        } catch {
            let msg = error.localizedDescription
            PopUpGenerator.shared.show(msg: msg.contains("full") ? "Capacity reached." : "Error: \(msg)",
                                       type: msg.contains("full") ? .warning : .error)
            await loadQueue()
        }
    }

    func confirmEventFinalChoice(selectedDateEntry: DateLocationEntry, selectedLocation: LocationPoint, finalStartDate: Date, finalEndDate: Date) async {
        isLoading = true
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

        // Aggiorniamo sia l'array dateLocations sia le variabili alla root per coprire ogni casistica del backend
        batch.updateData([
            "isDateConfirmed": true,
            "isLocationConfirmed": true,
            "status": UsersEventStatus.confirmed.rawValue,
            "dateLocations": finalizedDateLocation,
            "startDateTime": Timestamp(date: finalStartDate),
            "endDateTime": Timestamp(date: finalEndDate)
        ], forDocument: eventRef)

        do {
            // MARK: - LOGICA FLATTENED EVENTS CORRETTA
            let flattenedSnapshot = try await db.collection("flattenedEvents")
                .whereField("eventId", isEqualTo: eventId)
                .getDocuments()

            for doc in flattenedSnapshot.documents {
                let data = doc.data()

                // Controlliamo chiavi multiple nel caso i nomi nel database siano differenti
                let docDateLocationId = (data["dateLocationId"] as? String) ?? (data["id"] as? String) ?? ""

                let docGeohash = (data["g"] as? [String: Any])?["geohash"] as? String
                                 ?? data["geohash"] as? String
                                 ?? ""

                let isChosenEntry = (docDateLocationId == selectedDateEntry.id)
                let isChosenLocation = (docGeohash == selectedLocation.geohash)

                // Fallback nel caso il geohash manchi ma le coordinate corrispondano
                var coordinateMatch = false
                if let geoPoint = data["geoPoint"] as? GeoPoint {
                    let latDiff = abs(geoPoint.latitude - selectedLocation.latitude)
                    let lonDiff = abs(geoPoint.longitude - selectedLocation.longitude)
                    coordinateMatch = (latDiff < 0.0001 && lonDiff < 0.0001)
                }

                // Se troviamo quello giusto, lo aggiorniamo sovrascrivendo le date con quelle precise!
                if isChosenEntry && (isChosenLocation || coordinateMatch) {
                    batch.updateData([
                        "startDateTime": Timestamp(date: finalStartDate),
                        "endDateTime": Timestamp(date: finalEndDate),
                        "isDateConfirmed": true,
                        "isLocationConfirmed": true
                    ], forDocument: doc.reference)
                } else {
                    // Quelli scartati vengono definitivamente eliminati
                    batch.deleteDocument(doc.reference)
                }
            }
            try await batch.commit()
            await loadDetails()
            isLoading = false
        } catch {
            logger.error("Error confirming event: \(error.localizedDescription)")
            isLoading = false
            PopUpGenerator.shared.show(msg: "Error confirming event", type: .error)
        }
    }

    func navigateToConfirmationForSessionOrNavigateToSessionDetails() {
        Task {
            if !isSessionCreated { activeSheet = .startSessionConfirmation }
            else if let mainCoordinator { mainCoordinator.navigateTo(.creatorSession(eventDetails: myEventDertails!, isSessionCreated: true)) }
        }
    }

    func checkIsSessionCreated() async throws -> Bool {
        let repo = OnGoingSessionRepository()
        var queryRef = repo.initQueryBuilderObject()
        queryRef = queryRef.appendFilter(Filter(field: repo.constants.eventId, operation: .isEqualTo, value: eventId))
        let sessions = try await repo.fetch(query: queryRef)
        return sessions.count != 0
    }

    func deleteEvent() async {
        isDeletingEvent = true
        do {
            try await deleteRequester.deleteEvent(eventId: eventId)
            isDeletingEvent = false
            eventDeleted = true
            PopUpGenerator.shared.show(msg: "Event deleted successfully", type: .notification)
        } catch {
            logger.error("Error deleting event: \(error.localizedDescription)")
            isDeletingEvent = false
            PopUpGenerator.shared.show(msg: "Error deleting event", type: .error)
        }
    }
}
