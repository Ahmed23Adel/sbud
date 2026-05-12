//
//  HomeTabsViewModel.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class HomeTabsViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var unreadMessagesCount = 0//for the badge in the profile tab
    
    private var listenerRegistration: ListenerRegistration?

        init() {
            listenForUnreadMessages()
        }
        
        deinit {
            listenerRegistration?.remove()
        }

        private func listenForUnreadMessages() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            // Listen for "recent-messages" where isRead is false
            let query = Firestore.firestore()
                .collection("messages")
                .document(uid)
                .collection("recent-messages")
                .whereField("isRead", isEqualTo: false) //adding in the message
            
            listenerRegistration = query.addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                // Update the number on the main queue
                DispatchQueue.main.async {
                    self.unreadMessagesCount = documents.count
                }
            }
        }
}
