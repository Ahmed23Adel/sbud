//
//  ViewModelMoreInfoEvent.swift
//  sbud
//
//  Created by ahmed on 02/02/2026.
//

import Foundation
import FirebaseAuth
import OSLog

enum JoinState: Equatable {
    case idle
    case pending
    case waitlisted(position: Int)
    case confirmed
    case rejected
    case withdrawn
    case full

    var isDisabled: Bool {
        switch self {
        case .idle, .withdrawn, .rejected: return false
        default: return true
        }
    }

    var labelText: String {
        switch self {
        case .idle, .withdrawn:        return "Join Activity"
        case .pending:                 return "Request Sent"
        case .waitlisted(let pos):     return "Waitlist #\(pos)"
        case .confirmed:               return "Joined ✓"
        case .rejected:                return "Rejected"
        case .full:                    return "Event Full"
        }
    }

    var iconName: String {
        switch self {
        case .idle, .withdrawn, .rejected: return "door.left.hand.open"
        case .pending:                     return "clock"
        case .waitlisted:                  return "list.number"
        case .confirmed:                   return "checkmark.circle.fill"
        case .full:                        return "person.fill.xmark"
        }
    }

    var canLeave: Bool { self == .confirmed }

    var canWithdraw: Bool {
        switch self {
        case .pending, .waitlisted: return true
        default: return false
        }
    }
}

@Observable
class ViewModelMoreInfoEvent {
    let eventId: String
    let logger = Logger(subsystem: "sBud", category: "MoreInfo")

    var fullDetails: EventFullDetails? = nil
    var isLoading = false
    var isErrorLoading = false

    var joinState: JoinState = .idle
    var isJoiningLoading = false
    var isCurrentUserHost = false

    var queueResponse: JoinQueueResponse? = nil
    var isLoadingQueue = false
    var showQueue = false

    private let joinRequester = JoinEventRequester()

    init(eventId: String) {
        logger.info("Selected activity: \(eventId)")
        self.eventId = eventId
        Task { await loadDetails() }
    }

    private func loadDetails() async {
        await MainActor.run { isLoading = true }
        do {
            async let detailsTask = EventByIdRequester().fetchEvent(eventId: eventId)
            async let roleTask = EventRoleService.getRole(eventId: eventId)

            let (details, role) = try await (detailsTask, roleTask)
            let isHost = role == .creator || role == .acceptedHost

            await MainActor.run {
                fullDetails = details
                isLoading = false
                isErrorLoading = false
                isCurrentUserHost = isHost
            }

            if isHost {
                await loadQueue()
            } else {
                await loadMyStatus()
            }
            logger.log("Full event loaded \(self.eventId), isHost: \(isHost)")
        } catch {
            logger.error("loadDetails error: \(error)")
            await MainActor.run {
                isErrorLoading = true
                isLoading = false
            }
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
            logger.error("loadQueue error: \(error)")
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
            PopUpGenerator.shared.show(msg: "Error: \(error.localizedDescription)", type: .error)
            await loadQueue()
        }
    }

    private func loadMyStatus() async {
        do {
            let resp = try await joinRequester.getMyStatus(eventId: eventId)
            await MainActor.run {
                switch resp.status {
                case "pending":    joinState = .pending
                case "confirmed":  joinState = .confirmed
                case "rejected":   joinState = .rejected
                case "withdrawn", "left": joinState = .withdrawn
                case "waitlisted": joinState = .waitlisted(position: resp.waitlistPosition ?? 0)
                default:           joinState = .idle
                }
            }
        } catch {
            logger.error("loadMyStatus error: \(error)")
            await MainActor.run { joinState = .idle }
        }
    }

    func joinEvent() async {
        await MainActor.run { isJoiningLoading = true }
        do {
            let resp = try await joinRequester.joinEvent(eventId: eventId)
            await MainActor.run {
                isJoiningLoading = false
                switch resp.status {
                case "confirmed":
                    joinState = .confirmed
                    PopUpGenerator.shared.show(msg: "You have joined the event!", type: .notification)
                case "pending":
                    joinState = .pending
                    PopUpGenerator.shared.show(msg: "Request sent, awaiting host approval.", type: .notification)
                case "waitlisted":
                    joinState = .waitlisted(position: 0)
                    PopUpGenerator.shared.show(msg: resp.message, type: .information)
                    Task { await self.loadMyStatus() }
                default:
                    break
                }
            }
        } catch {
            await MainActor.run {
                isJoiningLoading = false
                let msg = error.localizedDescription
                if msg.contains("full") {
                    joinState = .full
                    PopUpGenerator.shared.show(msg: "Event is full.", type: .warning)
                } else if msg.contains("Already") {
                    PopUpGenerator.shared.show(msg: "Already joined.", type: .warning)
                } else {
                    PopUpGenerator.shared.show(msg: "Error: \(msg)", type: .error)
                }
            }
        }
    }

    func withdraw() async {
        do {
            _ = try await joinRequester.withdraw(eventId: eventId)
            await MainActor.run {
                joinState = .withdrawn
                PopUpGenerator.shared.show(msg: "Withdrawn. You can re-join anytime.", type: .information)
            }
        } catch {
            PopUpGenerator.shared.show(msg: "Error: \(error.localizedDescription)", type: .error)
        }
    }

    func leave() async {
        do {
            _ = try await joinRequester.leave(eventId: eventId)
            await MainActor.run {
                joinState = .withdrawn
                PopUpGenerator.shared.show(msg: "You have left the event. You can re-join anytime.", type: .information)
            }
        } catch {
            PopUpGenerator.shared.show(msg: "Error: \(error.localizedDescription)", type: .error)
        }
    }
}
