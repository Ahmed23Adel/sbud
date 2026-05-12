//
//  EventUnreadBadge.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 11/05/2026.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

// 1. ViewModel dedicato per mantenere in vita il Listener
class BadgeViewModel: ObservableObject {
    @Published var unreadCount: Int = 0
    private var listener: ListenerRegistration?
    let eventId: String
    
    init(eventId: String) {
        self.eventId = eventId
        startListening()
    }
    
    deinit {
        listener?.remove()
    }
    
    private func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = Firestore.firestore()
            .collection("messages")
            .document(uid)
            .collection("recent-messages")
            .whereField("eventId", isEqualTo: eventId)
        
        listener = query.addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Filtriamo manualmente in RAM per non rompere gli indici di Firebase
                let unreadDocs = snapshot?.documents.filter { document in
                    let data = document.data()
                    return (data["isRead"] as? Bool) == false
                } ?? []
                
                self.unreadCount = unreadDocs.count
            }
        }
    }
}

// 2. La View che mostra il pallino
struct EventUnreadBadge: View {
    @StateObject private var viewModel: BadgeViewModel
    
    init(eventId: String) {
        // Inizializza lo StateObject con il ViewModel corretto
        _viewModel = StateObject(wrappedValue: BadgeViewModel(eventId: eventId))
    }
    
    var body: some View {
        Group {
            if viewModel.unreadCount > 0 {
                Text("\(viewModel.unreadCount)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .clipShape(Capsule())
            }
        }
    }
}
