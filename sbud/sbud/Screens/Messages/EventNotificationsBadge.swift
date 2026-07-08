//
//  EventNotificationsBadge.swift
//  sbud
//
//  Created by ahmed on 08/07/2026.
//

import SwiftUI
import FirebaseFirestore

struct EventNotificationsBadge: View {
    let eventId: String
    @State private var count: Int = 0
    @State private var listener: ListenerRegistration?

    var body: some View {
        ZStack {
            if count > 0 {
                Text("\(count)")
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
                let data = snapshot?.data() ?? [:]
                let unreadMessages = data["unreadMessagesCount"] as? Int ?? 0
                let pendingRequests = data["pendingRequestsCount"] as? Int ?? 0
                DispatchQueue.main.async {
                    self.count = unreadMessages + pendingRequests
                }
            }
    }
}
