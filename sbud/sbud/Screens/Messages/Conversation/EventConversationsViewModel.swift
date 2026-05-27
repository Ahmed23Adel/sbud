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

class EventConversationsViewModel: ObservableObject {
    
    @Published var recentMessages = [Message]()
    let eventId: String
    private var listener: ListenerRegistration?
    
    init(eventId: String) {
        self.eventId = eventId
    }
    
    deinit {
        listener?.remove()
    }
    
    
    func loadData() {
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
