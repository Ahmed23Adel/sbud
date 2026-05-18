//
//  ViewModelMoreInfoEvent.swift
//  sbud
//
//  Created by ahmed on 02/02/2026.
//

import Foundation
import FirebaseAuth
import OSLog
import FirebaseFirestore

enum JoinState: Equatable {
    case idle
    case pending
    case waitlisted(position: Int)
    case confirmed
    case rejected
    case withdrawn
    case left
    case full

    var isDisabled: Bool {
        switch self {
        case .idle, .withdrawn, .rejected, .left: return false
        default: return true
        }
    }

    var labelText: String {
        switch self {
        case .idle, .withdrawn, .left: return "Join Activity"
        case .pending:                 return "Request Sent"
        case .waitlisted(let pos):     return "Waitlist #\(pos)"
        case .confirmed:               return "Joined ✓"
        case .rejected:                return "Rejected"
        case .full:                    return "Event Full"
        }
    }

    var iconName: String {
        switch self {
        case .idle, .withdrawn, .rejected, .left: return "door.left.hand.open"
        case .pending:                            return "clock"
        case .waitlisted:                         return "list.number"
        case .confirmed:                          return "checkmark.circle.fill"
        case .full:                               return "person.fill.xmark"
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
    
    // NUOVE VARIABILI PER I PARTECIPANTI
    var confirmedParticipants: [UserProfile] = []
    var isLoadingParticipants = false
    
    private let joinRequester = JoinEventRequester()

    init(eventId: String) {
        logger.info("Selected activity: \(eventId)")
        self.eventId = eventId
        Task { await loadDetails() }
    }

    private func loadDetails() async {
        await MainActor.run { isLoading = true }
        do {
            let details = try await EventByIdRequester().fetchEvent(eventId: eventId)
            let uid = Auth.auth().currentUser?.uid ?? ""
            let isHost = !uid.isEmpty && details.creator.id == uid

            await MainActor.run {
                fullDetails = details
                isLoading = false
                isErrorLoading = false
                isCurrentUserHost = isHost
            }

            if !isHost {
                await loadMyStatus()
            }
            
            await fetchParticipants()
            
            logger.log("Full event loaded \(self.eventId)")
        } catch {
            logger.error("loadDetails error: \(error)")
            await MainActor.run {
                isErrorLoading = true
                isLoading = false
            }
            PopUpGenerator.shared.show(msg: "Error loading the event", type: .error)
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
    
    private func loadMyStatus() async {
        do {
            let resp = try await joinRequester.getMyStatus(eventId: eventId)
            await MainActor.run {
                switch resp.status {
                case "pending":    joinState = .pending
                case "confirmed":  joinState = .confirmed
                case "rejected":   joinState = .rejected
                case "withdrawn":  joinState = .withdrawn
                case "left":       joinState = .left
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
                joinState = .left
                PopUpGenerator.shared.show(msg: "You have left the event.", type: .information)
            }
        } catch {
            PopUpGenerator.shared.show(msg: "Error: \(error.localizedDescription)", type: .error)
        }
    }
}
