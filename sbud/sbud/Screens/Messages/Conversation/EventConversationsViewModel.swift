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
    
    // Niente più 'async', impostiamo il listener in tempo reale
    func loadData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore().collection("messages")
            .document(uid)
            .collection("recent-messages")
            .whereField("eventId", isEqualTo: eventId)
        
        listener?.remove() // Previeni duplicati se chiamato due volte
        
        listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Errore in EventConversationsViewModel: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var messages: [Message] = []
            
            for document in documents {
                if let msg = try? document.data(as: Message.self) {
                    messages.append(msg)
                }
            }
            
            messages.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
            
            // Scarica i profili utente senza bloccare il thread principale
            Task {
                var updatedMessages = messages
                var profilesMap = [String: UserProfile]()
                
                for i in 0 ..< updatedMessages.count {
                    let partnerId = updatedMessages[i].chatPartnerId
                    
                    if let cachedUser = profilesMap[partnerId] {
                        updatedMessages[i].user = cachedUser
                    } else {
                        do {
                            let doc = try await Firestore.firestore().collection("users").document(partnerId).getDocument()
                            if let userProfile = try? doc.data(as: UserProfile.self) {
                                updatedMessages[i].user = userProfile
                                profilesMap[partnerId] = userProfile
                            }
                        } catch {
                            print("Error fetch user: \(error)")
                        }
                    }
                }
                
                await MainActor.run {
                    self.recentMessages = updatedMessages
                }
            }
        }
    }
}
