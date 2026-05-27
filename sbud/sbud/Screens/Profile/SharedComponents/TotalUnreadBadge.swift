//
//  TotalUnreadBadge.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 27/05/2026.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TotalUnreadBadge: View {
    @State private var unreadCount: Int = 0
    @State private var listener: ListenerRegistration?
    
    var body: some View {
        ZStack {
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
        .onDisappear {
            listener?.remove()
            listener = nil
        }
    }
    
    private func startListening() {
        guard listener == nil else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        
        let query = Firestore.firestore()
            .collection("messages")
            .document(uid)
            .collection("recent-messages")
        
        listener = query.addSnapshotListener { snapshot, _ in
            let messages = snapshot?.documents.compactMap { try? $0.data(as: Message.self) } ?? []
            let count = messages.filter { $0.isRead == false }.count
            
            DispatchQueue.main.async {
                self.unreadCount = count
            }
        }
    }
}
