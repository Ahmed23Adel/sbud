//
//  ViewModelOthersEventDetails.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import Foundation
import OSLog
import FirebaseFirestore

@Observable
class ViewModelOthersEventDetails {
    let logger = Logger(subsystem: "sBud", category: "ViewModelOthersEventDetails")

    var myEventDertails: EventFullDetails? = nil
    var isLoading: Bool = false
    var eventId: String
    var role: EventUserRole? = nil
    var queueResponse: JoinQueueResponse? = nil
    var isLoadingQueue: Bool = false
    var showQueue: Bool = false
    var isShowJoinSessionButton = false

    private let joinRequester = JoinEventRequester()

    init(eventId: String) {
        logger.info("eventId: \(eventId)")
        self.eventId = eventId
        Task { await loadDetails() }
        isSessionCreated(eventId: eventId)
    }

    private func loadDetails() async {
        await MainActor.run { isLoading = true }
        do {
            async let detailsTask = EventByIdRequester().fetchEvent(eventId: eventId)
            async let roleTask = EventRoleService.getRole(eventId: eventId)
            let (details, resolvedRole) = try await (detailsTask, roleTask)
            await MainActor.run {
                myEventDertails = details
                role = resolvedRole
                isLoading = false
            }
            if resolvedRole == .acceptedHost || resolvedRole == .creator {
                await loadQueue()
            }
            logger.log("Full others event loaded \(self.eventId), role: \(String(describing: resolvedRole))")
        } catch {
            logger.error("Error: \(error)")
            await MainActor.run { isLoading = false }
            PopUpGenerator.shared.show(msg: "Error loading the event", type: .error)
        }
    }

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
                PopUpGenerator.shared.show(msg: accept ? "Confirmed" : "Rejected.", type: accept ? .notification : .information)
            }
            await loadQueue()
        } catch {
            PopUpGenerator.shared.show(msg: "Error: \(error.localizedDescription)", type: .error)
            await loadQueue()
        }
    }

    private func isSessionCreated(eventId: String) {
        Task {
            let repo = OnGoingSessionRepository()
            var queryRef = repo.initQueryBuilderObject()
            queryRef = queryRef.appendFilter(Filter(field: repo.constants.eventId, operation: .isEqualTo, value: eventId))
            let sessions = try await repo.fetch(query: queryRef)
            isShowJoinSessionButton = sessions.count > 0
        }
    }
}
