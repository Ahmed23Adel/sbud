//
//  ViewModelMyEvents.swift
//  sbud
//
//  Created by ahmed on 30/04/2026.
//

import Foundation
import OSLog

@Observable
class ViewModelMyEvents{
    let userId: String
    var usersEvents: [UsersEvent] = []
    let logger = Logger(subsystem: "sbud", category: "ViewModelMyEvents")
    var isShowAlert = false
    var alertMsg = ""
    
    init(userId: String){
        logger.info("userId: \(userId)")
        self.userId = userId
        loadUsersEvents()
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
}
