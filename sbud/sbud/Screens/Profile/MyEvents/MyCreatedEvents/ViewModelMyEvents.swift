//
//  ViewModelMyEvents.swift
//  sbud
//
//  Created by ahmed on 30/04/2026.
//

import Foundation
import OSLog
import FirebaseAnalytics

enum MyEventsTab { case created, hosting }

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

    private let createdEventsFetcher: UsersEventFetching
    private let hostingEventsFetcher: HostingEventsFetching

    init(
        userId: String,
        createdEventsFetcher: UsersEventFetching = DefaultUsersEventFetcher(),
        hostingEventsFetcher: HostingEventsFetching = HostingEventsRequester(),
        autoStart: Bool = true
    ) {
        self.userId = userId
        self.createdEventsFetcher = createdEventsFetcher
        self.hostingEventsFetcher = hostingEventsFetcher
        logger.info("userId: \(userId)")
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "MyCreatedEvents"])
        guard autoStart else { return }
        Task { await loadCreatedEvents() }
        Task { await loadHostingEvents() }
    }

    func loadCreatedEvents() async {
        do {
            usersEvents = try await createdEventsFetcher.fetchCreatedEvents(userId: userId)
        } catch {
            alertMsg = "Error with loading events, please try again"
            isShowAlert = true
        }
    }

    func loadHostingEvents() async {
        isLoadingHosting = true
        defer { isLoadingHosting = false }
        do {
            hostingEvents = try await hostingEventsFetcher.fetchHostingEvents()
        } catch {
            logger.error("Error loading hosting events: \(error)")
        }
    }
}
