//
//  HostedEventsViewModel.swift
//  sbud
//
//  Created by ahmed on 22/05/2026.
//

import Foundation
import OSLog
@Observable
class HostedEventsViewModel {
    let logger = Logger(subsystem: "sbud", category: "HostedEventsViewModel")
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
        fetchHostedEvents()
    }

    private func fetchHostedEvents() {
        let repo = JoinedEventsRepository()
        var query = repo.initQueryBuilderObject()
        query = query.appendFilter(Filter(field: repo.constants.userId, operation: .isEqualTo, value: userId))
        query = query.appendFilter(Filter(field: repo.constants.participationStatus, operation: .isEqualTo, value: ParticipationStatus.host.rawValue))

        Task {
            do {
                joinedEvents = try await repo.fetch(query: query)
                logger.info("hosted count \(self.joinedEvents.count)")
            } catch {
                alertMsg = "Error with loading events, please try again"
                isShowAlert = true
                logger.fault("Error with loading hosted events")
            }
        }
    }
}
