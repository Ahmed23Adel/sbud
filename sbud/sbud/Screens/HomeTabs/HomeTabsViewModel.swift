//
//  HomeTabsViewModel.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class HomeTabsViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var unreadMessagesCount = 0
    private var listenerRegistration: ListenerRegistration?
    
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func listenForUnreadMessages() {
        // Evita che si creino doppi listener se la view si ricarica
        guard listenerRegistration == nil else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("⚠️ Errore: UID non ancora pronto per HomeTabsViewModel")
            return
        }
        
        let query = Firestore.firestore()
            .collection("messages")
            .document(uid)
            .collection("recent-messages")
        
        listenerRegistration = query.addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self else { return }
            
            // Usiamo la decodifica Message (sicura, visto che per i pallini funziona!)
            let messages = snapshot?.documents.compactMap { try? $0.data(as: Message.self) } ?? []
            let count = messages.filter { $0.isRead == false }.count
            
            DispatchQueue.main.async {
                self.unreadMessagesCount = count
            }
        }
    }
}
