//
//  ViewModelOthersEventDetails.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import Foundation
import OSLog
import FirebaseAnalytics

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

    var confirmedParticipants: [UserProfile] = []
    var isLoadingParticipants = false

    var joinState: JoinState = .idle
    var isJoiningLoading = false

    private let joinRequester = JoinEventRequester()

    init(eventId: String) {
        logger.info("eventId: \(eventId)")
        self.eventId = eventId
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "OthersEventDetails",
            "event_id": eventId
        ])
        Task { await loadDetails() }
        isSessionCreated(eventId: eventId)
    }

    // MARK: - Refresh

    /// Re-fetches event details and re-checks whether an active session exists.
    /// Called by pull-to-refresh in the view.
    func refresh() async {
        await loadDetails()
        await checkSession()
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
            } else {
                await loadMyStatus()
            }
            await fetchParticipants()
            logger.log("Full others event loaded \(self.eventId), role: \(String(describing: resolvedRole))")
        } catch {
            logger.error("Error: \(error)")
            await MainActor.run { isLoading = false }
            PopUpGenerator.shared.show(msg: "Error loading the event", type: .error)
        }
    }

    private func fetchParticipants() async {
        await MainActor.run { isLoadingParticipants = true }
        let profiles = await JoinedEventsRepository().fetchConfirmedParticipants(eventId: eventId)
        await MainActor.run {
            self.confirmedParticipants = profiles
            self.isLoadingParticipants = false
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

    func loadMyStatus() async {
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
            await EventReminderScheduler.shared.cancelReminderOnLeave(eventId: eventId)
        } catch {
            PopUpGenerator.shared.show(msg: "Error: \(error.localizedDescription)", type: .error)
        }
    }

    /// Leaves a joined event. Only meaningful for confirmed participants.
    /// Returns `true` on success so the view can pop back.
    func leave() async -> Bool {
        do {
            _ = try await joinRequester.leave(eventId: eventId)
            await EventReminderScheduler.shared.cancelReminderOnLeave(eventId: eventId)
            await MainActor.run {
                PopUpGenerator.shared.show(msg: "You have left the event", type: .information)
            }
            return true
        } catch {
            PopUpGenerator.shared.show(msg: "Error: \(error.localizedDescription)", type: .error)
            return false
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
        Task { await checkSession() }
    }

    /// Async version used by both the init-time check and pull-to-refresh.
    private func checkSession() async {
        let repo = OnGoingSessionRepository()
        var queryRef = repo.initQueryBuilderObject()
        queryRef = queryRef.appendFilter(Filter(field: repo.constants.eventId, operation: .isEqualTo, value: eventId))
        do {
            let sessions = try await repo.fetch(query: queryRef)
            logger.info("sessions count: \(sessions.count)")
            isShowJoinSessionButton = sessions.count != 0
        } catch {
            logger.error("Error checking session status: \(error)")

        }
    }
}
