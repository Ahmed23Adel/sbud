//
//  ViewModelJoinedEvents.swift
//  sbud
//
//  Created by ahmed on 14/05/2026.
//

import Foundation
import FirebaseFirestore
import OSLog
@Observable
class ViewModelJoinedEvents{
    let userId = ProfileManager.shared.getLocalProfile()?.id
    var participatedEvents: [UsersEvent] = []
    var sections: [(UsersEventStatus, [UsersEvent])] {
        let order: [UsersEventStatus] = [.confirmed, .proposed, .completed]
        let grouped = Dictionary(grouping: participatedEvents, by: \.status)
        return order.compactMap { status in
            guard let events = grouped[status], !events.isEmpty else { return nil }
            return (status, events)
        }
    }
    
    let logger = Logger(subsystem: "sbud", category: "ViewModelJoinedEvents")
    var isShowAlert = false
    var alertMsg = ""
    
    init(){
        if let userId {
            Task {
                do {
                    participatedEvents = try await getParticipatedEvents(forUserId: userId)
                    logger.info("participatedEvents len \(self.participatedEvents.count)")
                } catch {
                    logger.fault("Error with loading events: \(error)")
                    showAlert(msg: "Error with loading participated events, please try again later")
                }
            }
        }
    }
    
    func getParticipatedEvents(forUserId userId: String) async throws -> [UsersEvent] {
        let db = Firestore.firestore()

        let snapshot = try await db.collection("joinedEvents")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        print("snapshot")
        return snapshot.documents.compactMap { doc -> UsersEvent? in
            let data = doc.data()
            print("Data: ", data)
            guard let rawStatus = data["status"] as? String,
                  let status = UsersEventStatus(rawValue: rawStatus) else { return nil }

            var event = UsersEvent()
            event.eventId = data["eventId"] as? String ?? doc.documentID
            event.title = data["title"] as? String ?? ""
            event.eventImage = data["eventImage"] as? String ?? ""
            event.status = status

            if let rawActivity = data["activityType"] as? String {
                event.activityType = ActivityType(rawValue: rawActivity) ?? .running
            }

            return event
        }
    }
    
    
    private func showAlert(msg: String){
        alertMsg = msg
        isShowAlert = true
    }
}
