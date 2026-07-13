//
//  EventConversationsViewModel.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 04/05/26.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine
import FirebaseAnalytics

class EventConversationsViewModel: ObservableObject {

    @Published var recentMessages = [Message]()
    @Published var participants = [UserProfile]()
    let eventId: String
    private var listener: ListenerRegistration?

    /// Every confirmed participant except the creator themselves, surfaced as tappable
    /// avatars so the creator can start (or jump into) a chat with anyone in the event.
    /// We intentionally do NOT hide people who already messaged — they still appear here
    /// so the full participant roster is always visible; their thread also shows below.
    var messageableParticipants: [UserProfile] {
        let myUid = Auth.auth().currentUser?.uid
        return participants
            .filter { $0.id != myUid }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    init(eventId: String) {
        self.eventId = eventId
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "EventConversations",
            "event_id": eventId
        ])
    }

    deinit {
        listener?.remove()
    }


    func loadData() {
        Task { await loadParticipants() }
        listenForRecentMessages()
    }

    private func loadParticipants() async {
        let fetched = await JoinedEventsRepository().fetchParticipants(eventId: eventId)
        await MainActor.run { self.participants = fetched }
    }

    private func listenForRecentMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore().collection("messages")
            .document(uid)
            .collection("recent-messages")
            .whereField("eventId", isEqualTo: eventId)
        
        listener?.remove() // Rimuovi vecchi listener per evitare duplicati
                
        listener = query.addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self, let docs = snapshot?.documents else { return }
            
            var msgs = docs.compactMap { try? $0.data(as: Message.self) }
            msgs.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
            
            Task {
                var updatedMessages = msgs
                // Scarica i profili utente
                for i in 0 ..< updatedMessages.count {
                    let partnerId = updatedMessages[i].chatPartnerId
                    if let doc = try? await Firestore.firestore().collection("users").document(partnerId).getDocument(),
                       let userProfile = try? doc.data(as: UserProfile.self) {
                        updatedMessages[i].user = userProfile
                    }
                }
                
                await MainActor.run {
                    self.recentMessages = updatedMessages
                }
            }
        }
    }
}
