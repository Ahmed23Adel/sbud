//
//  HostEventViewModel.swift
//  sbud
//
//  Created by Erdal on 10.05.2026.
//

import Foundation
import OSLog

@Observable
class HostEventViewModel {
    let eventId: String
    let logger = Logger(subsystem: "sBud", category: "HostEventViewModel")

    var fullDetails: EventFullDetails? = nil
    var isLoading = false
    var isErrorLoading = false
    var queueResponse: JoinQueueResponse? = nil
    var isLoadingQueue = false
    var showQueue = false

    private let joinRequester = JoinEventRequester()

    init(eventId: String) {
        self.eventId = eventId
        Task { await loadDetails() }
    }

    func loadDetails() async {
        await MainActor.run { isLoading = true }
        do {
            let details = try await EventByIdRequester().fetchEvent(eventId: eventId)
            await MainActor.run {
                fullDetails = details
                isLoading = false
                isErrorLoading = false
            }
            await loadQueue()
        } catch {
            logger.error("loadDetails error: \(error)")
            await MainActor.run { isErrorLoading = true; isLoading = false }
            PopUpGenerator.shared.show(msg: "Error loading the event", type: .error)
        }
    }

    func loadQueue() async {
        await MainActor.run { isLoadingQueue = true }
        do {
            let q = try await joinRequester.getPendingQueue(eventId: eventId)
            await MainActor.run { queueResponse = q; isLoadingQueue = false }
        } catch {
            await MainActor.run { isLoadingQueue = false }
        }
    }

    func respondToRequest(requesterId: String, accept: Bool) async {
        do {
            _ = try await joinRequester.respondToRequest(eventId: eventId, requesterId: requesterId, accept: accept)
            await MainActor.run {
                if var q = queueResponse {
                    q.pendingUsers.removeAll { $0.userId == requesterId }
                    if accept { q.confirmedCount += 1 } else { q.pendingCount = max(0, q.pendingCount - 1) }
                    q.isCapacityFull = (q.capacity != nil && q.confirmedCount >= q.capacity!)
                    queueResponse = q
                }
                PopUpGenerator.shared.show(msg: accept ? "Confirmed" : "Rejected.", type: accept ? .notification : .information)
            }
            await loadQueue()
        } catch {
            let msg = error.localizedDescription
            PopUpGenerator.shared.show(msg: msg.contains("full") ? "Capacity reached." : "Error: \(msg)", type: .error)
            await loadQueue()
        }
    }
}
