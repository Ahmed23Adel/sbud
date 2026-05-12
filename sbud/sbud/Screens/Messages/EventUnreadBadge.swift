//
//  EventUnreadBadge.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 11/05/2026.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct EventUnreadBadge: View {
    let eventId: String
    @State private var unreadCount: Int = 0
    @State private var listener: ListenerRegistration?
    
    var body: some View {
        Group {
            if unreadCount > 0 {
                Text("\(unreadCount)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .clipShape(Capsule())
            }
        }
        .onAppear { startListening() }
        .onDisappear { listener?.remove() }
    }
    
    private func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = Firestore.firestore()
            .collection("messages")
            .document(uid)
            .collection("recent-messages")
            .whereField("eventId", isEqualTo: eventId)
            // RIMOSSO IL SECONDO WHEREFIELD PER EVITARE IL CRASH DEGLI INDICI
        
        listener = query.addSnapshotListener { snapshot, _ in
            DispatchQueue.main.async {
                // Filtriamo noi localmente i documenti con isRead == false
                let unreadDocs = snapshot?.documents.filter { document in
                    let data = document.data()
                    return (data["isRead"] as? Bool) == false
                } ?? []
                
                self.unreadCount = unreadDocs.count
            }
        }
    }
}
