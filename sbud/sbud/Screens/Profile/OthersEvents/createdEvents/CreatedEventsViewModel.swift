//
//  CreatedEventsViewModel.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import Foundation
import OSLog
@Observable
class CreatedEventsViewModel{
    let logger = Logger(subsystem: "sbud", category: "CreatedEventsViewModel")
    let userId: String
    var usersEvents: [UsersEvent] = []
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
        self.userId = userId
        fetchCreatedEvents()
    }
    

    
    private func fetchCreatedEvents(){
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

    func reloadEvents() {
        fetchCreatedEvents()
    }

}
