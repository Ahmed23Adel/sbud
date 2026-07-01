//
//  ParticipatedEventsViewModel.swift
//  sbud
//
//  Created by ahmed on 22/05/2026.
//


import Foundation
import OSLog

@Observable
class ParticipatedEventsViewModel {
    let logger = Logger(subsystem: "sbud", category: "ParticipatedEventsViewModel")
    let userId: String
    var joinedEvents: [JoinedEvent] = []
    var isShowAlert = false
    var alertMsg = ""

    var sections: [(UsersEventStatus, [JoinedEvent])] {
        let order: [UsersEventStatus] = [.confirmed, .proposed, .completed]
        let grouped = Dictionary(grouping: joinedEvents, by: \.status)
        return order.compactMap { status in
            guard let events = grouped[status], !events.isEmpty else { return nil }
            return (status, events)
        }
    }

    init(userId: String) {
        self.userId = userId
        fetchParticipatedEvents()
    }

    func reloadEvents() {
        fetchParticipatedEvents()
    }

    private func fetchParticipatedEvents() {
        let repo = JoinedEventsRepository()
        var query = repo.initQueryBuilderObject()
        query = query.appendFilter(Filter(field: repo.constants.userId, operation: .isEqualTo, value: userId))
        query = query.appendFilter(Filter(field: repo.constants.participationStatus, operation: .isEqualTo, value: ParticipationStatus.participant.rawValue ))
        Task {
            do {
                joinedEvents = try await repo.fetch(query: query)
                logger.info("participated count \(self.joinedEvents.count)")
            } catch {
                alertMsg = "Error with loading events, please try again"
                isShowAlert = true
                logger.fault("Error with loading participated events")
            }
        }
    }
}
