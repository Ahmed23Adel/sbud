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
    func loadData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore().collection("messages")
            .document(uid)
            .collection("recent-messages")
            .whereField("eventId", isEqualTo: eventId)
        
        do {
            
            let snapshot = try await query.getDocuments()
            var messages = snapshot.documents.compactMap({ try? $0.data(as: Message.self) })
            
            
            messages.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
            
            var profilesMap = [String: UserProfile]()
            
            for i in 0 ..< messages.count {
                let partnerId = messages[i].chatPartnerId
                
                
                if let cachedUser = profilesMap[partnerId] {
                    messages[i].user = cachedUser
                } else {
                    do {
                        let doc = try await Firestore.firestore().collection("users").document(partnerId).getDocument()
                        if let userProfile = try? doc.data(as: UserProfile.self) {
                            messages[i].user = userProfile
                            profilesMap[partnerId] = userProfile
                        }
                    } catch {
                        print("Errore nel fetch dell'utente: \(error)")
                    }
                }
            }
            
            
            self.recentMessages = messages
            
        } catch {
            print("Errore durante il caricamento delle conversazioni: \(error)")
        }
    }
}
