//
//  ViewModelMoreInfoEvent.swift
//  sbud
//
//  Created by ahmed on 02/02/2026.
//

import Foundation
import OSLog
import FirebaseAnalytics
import FirebaseFirestore

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

    var confirmedParticipants: [UserProfile] = []
    var isLoadingParticipants = false

    private let joinRequester: JoinEventRequesting
    private let eventFetcher: EventFetching
    private let currentUserProvider: CurrentUserProviding

    init(
        eventId: String,
        joinRequester: JoinEventRequesting = JoinEventRequester(),
        eventFetcher: EventFetching = EventByIdRequester(),
        currentUserProvider: CurrentUserProviding = FirebaseCurrentUserProvider()
    ) {
        logger.info("Selected activity: \(eventId)")
        self.eventId = eventId
        self.joinRequester = joinRequester
        self.eventFetcher = eventFetcher
        self.currentUserProvider = currentUserProvider
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "EventDetails",
            "event_id": eventId
        ])
        Task { await loadDetails() }
    }

    func loadDetails() async {
        await MainActor.run { isLoading = true }
        do {
            let details = try await eventFetcher.fetchEvent(eventId: eventId)
            let uid = currentUserProvider.currentUserId ?? ""
            let isHost = !uid.isEmpty && details.creator.id == uid

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
            await fetchParticipants()

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

    private func fetchParticipants() async {
        await MainActor.run { isLoadingParticipants = true }

        do {
            let db = Firestore.firestore()
            logger.info("Search participants in joinedEvents by event: \(self.eventId)")

            let snapshot = try await db.collection("joinedEvents")
                .whereField("eventId", isEqualTo: self.eventId)
                .whereField("status", in: ["Confirmed", "confirmed"])
                .getDocuments()

            logger.info("Found \(snapshot.documents.count) partecipants in joinedEvents")

            var profiles: [UserProfile] = []

            for doc in snapshot.documents {
                let data = doc.data()

                if let userId = data["userId"] as? String {
                    var profile = UserProfile(id: userId)

                    profile.name = data["userFirstName"] as? String ?? "Utente"
                    profile.surName = data["userLastName"] as? String ?? ""
                    profile.profileImageUrl = data["userProfileImageUrl"] as? String

                    profiles.append(profile)
                    logger.info("Partecipante aggiunto: \(profile.name) \(profile.surName)")
                }
            }

            await MainActor.run {
                self.confirmedParticipants = profiles
                self.isLoadingParticipants = false
            }

        } catch {
            logger.error("CRITICAL ERROR: fetchParticipants (joinedEvents): \(error.localizedDescription)")
            await MainActor.run { self.isLoadingParticipants = false }
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
            if resp.status == "confirmed", let start = fullDetails?.finalStartDateTime {
                await EventReminderScheduler.shared.scheduleReminder(
                    eventId: eventId,
                    title: fullDetails?.title ?? "",
                    activityType: fullDetails?.activityType ?? .running,
                    startDateTime: start
                )
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

    func leave() async {
        do {
            _ = try await joinRequester.leave(eventId: eventId)
            await MainActor.run {
                joinState = .withdrawn
                PopUpGenerator.shared.show(msg: "You have left the event. You can re-join anytime.", type: .information)
            }
            await EventReminderScheduler.shared.cancelReminderOnLeave(eventId: eventId)
        } catch {
            PopUpGenerator.shared.show(msg: "Error: \(error.localizedDescription)", type: .error)
        }
    }
}
