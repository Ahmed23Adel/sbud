//
//  EventUnreadBadge.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 26/05/2026.
//

import SwiftUI
import FirebaseFirestore

struct EventUnreadBadge: View {
    let eventId: String
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

        listener = Firestore.firestore()
            .collection("Events")
            .document(eventId)
            .addSnapshotListener { snapshot, _ in
                let count = snapshot?.data()?["unreadMessagesCount"] as? Int ?? 0
                DispatchQueue.main.async {
                    self.unreadCount = count
                }
            }
    }
}
