//
//  ViewModelMyEvents.swift
//  sbud
//
//  Created by ahmed on 30/04/2026.
//

import Foundation
import OSLog
import FirebaseAnalytics

@Observable
class ViewModelMyEvents{
    let userId: String
    var usersEvents: [UsersEvent] = []
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
    
    init(userId: String){
        logger.info("userId: \(userId)")
        self.userId = userId
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "MyCreatedEvents"])
        loadUsersEvents()
    }
    
    
    // TODO: Make sure you can have access to the following event public/private
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
}
