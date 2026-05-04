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
    
    init(eventId: String) {
        self.eventId = eventId
    }
    
    @MainActor
    func loadData() {
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
           
            let query = Firestore.firestore().collection("messages")
                .document(uid)
                .collection("recent-messages")
                .whereField("eventId", isEqualTo: eventId) 
            
            do {
                let snapshot = try await query.getDocuments()
                var messages = snapshot.documents.compactMap({ try? $0.data(as: Message.self) })
                
                
                messages.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
                
                
                for i in 0 ..< messages.count {
                    let partnerId = messages[i].chatPartnerId
                    
                    
                    let doc = try await Firestore.firestore().collection("users").document(partnerId).getDocument()
                    if let userProfile = try? doc.data(as: UserProfile.self) {
                        messages[i].user = userProfile
                    }
                }
                
                self.recentMessages = messages
            } catch {
                print("Error loading recent messages: \(error)")
            }
        }
    }
}
