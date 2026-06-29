//
//  ViewModelMyEvents.swift
//  sbud
//
//  Created by ahmed on 30/04/2026.
//

import Foundation
import OSLog
import FirebaseAnalytics

enum MyEventsTab {
    case created
    case hosting
}

@Observable
class ViewModelMyEvents {
    let userId: String
    var usersEvents: [UsersEvent] = []
    var hostingEvents: [HostingEvent] = []
    var selectedTab: MyEventsTab = .created
    var isLoadingHosting: Bool = false
    let logger = Logger(subsystem: "sbud", category: "ViewModelMyEvents")
    var isShowAlert = false
    var alertMsg = ""

    var sections: [(UsersEventStatus, [UsersEvent])] {
        let order: [UsersEventStatus] = [.confirmed, .proposed, .completed]
        let grouped = Dictionary(grouping: usersEvents, by: \.status)
        return order.compactMap { status in
            guard let events = grouped[status], !events.isEmpty else { return nil }
            return (status, events)
        }
    }

    var hostingSections: [(UsersEventStatus, [HostingEvent])] {
        let order: [UsersEventStatus] = [.confirmed, .proposed, .completed]
        let grouped = Dictionary(grouping: hostingEvents, by: \.usersEventStatus)
        return order.compactMap { status in
            guard let events = grouped[status], !events.isEmpty else { return nil }
            return (status, events)
        }
    }

    init(userId: String) {
        logger.info("userId: \(userId)")
        self.userId = userId
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "MyCreatedEvents"])
        loadUsersEvents()
        Task { await loadHostingEvents() }
    }

    private func loadUsersEvents() {
        let repo = UsersEventRepository()
        var query = repo.initQueryBuilderObject()
        query = query.appendFilter(Filter(field: repo.constants.creatorId, operation: .isEqualTo, value: userId))

        Task {
            do {
                usersEvents = try await repo.fetch(query: query)
                logger.info("usersEvents count \(self.usersEvents.count)")
            } catch {
                alertMsg = "Error with loading events, please try again"
                isShowAlert = true
                logger.fault("Error with loading my events")
            }
        }
    }

    func loadHostingEvents() async {
        await MainActor.run { isLoadingHosting = true }
        do {
            let events = try await HostingEventsRequester().fetchHostingEvents()
            await MainActor.run {
                hostingEvents = events
                isLoadingHosting = false
            }
            logger.info("hostingEvents count \(events.count)")
        } catch {
            await MainActor.run { isLoadingHosting = false }
            logger.error("Error loading hosting events: \(error)")
        }
    }
}
