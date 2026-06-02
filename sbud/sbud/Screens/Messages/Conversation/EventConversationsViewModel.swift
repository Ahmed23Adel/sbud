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
    let eventId: String
    
    init(eventId: String) {
        self.eventId = eventId
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "EventConversations",
            "event_id": eventId
        ])
    }
    
    @MainActor
    func loadData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore().collection("messages")
            .document(uid)
            .collection("recent-messages")
            .whereField("eventId", isEqualTo: eventId)
        
        do {
            
            let snapshot = try await query.getDocuments(source: .server)
            
            var messages: [Message] = []
            
            
            for document in snapshot.documents {
                do {
                    let msg = try document.data(as: Message.self)
                    messages.append(msg)
                } catch {
                    print("❌ ERROR \(document.documentID): \(error)")
                }
            }
            
            
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
                        print("Error nel fetch user \(partnerId): \(error)")
                    }
                }
            }
            
            self.recentMessages = messages
            print("✅ Find \(self.recentMessages.count) \(eventId)")
            
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
