//
//  EventReminderScheduler.swift
//  sbud
//
//  Created by ahmed on 03/06/2026.
//

import Foundation
import UserNotifications
import FirebaseFirestore
import OSLog

private let bgTaskIdentifier = "com.sbud.event.remindersync"

actor EventReminderScheduler {
    static let shared = EventReminderScheduler()
    private let logger = Logger(subsystem: "sbud", category: "EventReminderScheduler")
    private let center = UNUserNotificationCenter.current()

    private func notificationId(for eventId: String) -> String {
        "sbud.event-reminder.\(eventId)"
    }

    // Schedules a reminder at 7 pm the evening before the event.
    // Only schedules if startDateTime is tomorrow. Safe to call repeatedly —
    // re-adding the same identifier replaces the existing request.
    func scheduleReminder(
        eventId: String,
        title: String,
        activityType: ActivityType,
        startDateTime: Date
    ) async {
        guard Calendar.current.isDateInTomorrow(startDateTime) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Activity Tomorrow"
        content.body = "You have \"\(title)\" tomorrow. Get ready!"
        content.sound = .default

        var triggerComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        triggerComponents.hour = 19
        triggerComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationId(for: eventId),
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            logger.info("Scheduled reminder for event \(eventId) — \(title)")
        } catch {
            logger.error("Failed to schedule reminder for \(eventId): \(error)")
        }
    }

    func cancelReminder(eventId: String) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationId(for: eventId)])
        logger.info("Cancelled reminder for event \(eventId)")
    }

    // Placeholder: call this when the user leaves or withdraws from an event.
    // Wire it to the leave/withdraw completion handlers in ViewModelMoreInfoEvent
    // once that feature is fully implemented.
    func cancelReminderOnLeave(eventId: String) {
        cancelReminder(eventId: eventId)
    }

    // Full reconciliation: fetches all events the current user is confirmed to attend
    // or has created, schedules reminders for those happening tomorrow, and cancels
    // any pending reminders for events no longer relevant.
    func syncReminders() async {
        guard let userId = ProfileManager.shared.getLocalProfile()?.id else { return }
        logger.info("Starting reminder sync for user \(userId)")

        do {
            let eventIds = try await fetchRelevantEventIds(userId: userId)

            let details = await withTaskGroup(of: EventFullDetails?.self) { group in
                for eventId in eventIds {
                    group.addTask { try? await EventByIdRequester().fetchEvent(eventId: eventId) }
                }
                var results: [EventFullDetails] = []
                for await detail in group {
                    if let d = detail { results.append(d) }
                }
                return results
            }

            let tomorrowEvents = details.filter { event in
                guard let start = event.finalStartDateTime else { return false }
                return Calendar.current.isDateInTomorrow(start)
            }
            let tomorrowIds = Set(tomorrowEvents.map { $0.id })

            // Cancel pending reminders for events not happening tomorrow
            let pending = await center.pendingNotificationRequests()
            let prefix = "sbud.event-reminder."
            let staleNotificationIds = pending
                .map(\.identifier)
                .filter { $0.hasPrefix(prefix) }
                .filter { id in
                    let eventId = String(id.dropFirst(prefix.count))
                    return !tomorrowIds.contains(eventId)
                }

            if !staleNotificationIds.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: staleNotificationIds)
                logger.info("Cancelled \(staleNotificationIds.count) stale reminder(s)")
            }

            for event in tomorrowEvents {
                guard let start = event.finalStartDateTime else { continue }
                await scheduleReminder(
                    eventId: event.id,
                    title: event.title,
                    activityType: event.activityType,
                    startDateTime: start
                )
            }

            logger.info("Sync complete — \(tomorrowEvents.count) reminder(s) scheduled")
        } catch {
            logger.error("syncReminders failed: \(error)")
        }
    }

    // Queries `joinedEvents` (confirmed participant) and `Events` (creator)
    // to build the set of event IDs the user cares about.
    private func fetchRelevantEventIds(userId: String) async throws -> Set<String> {
        var ids = Set<String>()
        let db = Firestore.firestore()

        let joinedSnapshot = try await db.collection("joinedEvents")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: UsersEventStatus.confirmed.rawValue)
            .whereField("participationStatus", isEqualTo: ParticipationStatus.participant.rawValue)
            .getDocuments()

        for doc in joinedSnapshot.documents {
            if let eventId = doc.data()["eventId"] as? String {
                ids.insert(eventId)
            }
        }

        let createdSnapshot = try await db.collection("Events")
            .whereField("creatorId", isEqualTo: userId)
            .getDocuments()

        for doc in createdSnapshot.documents {
            ids.insert(doc.documentID)
        }

        logger.info("Found \(ids.count) relevant event IDs for sync")
        return ids
    }
}
