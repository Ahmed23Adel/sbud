//
//  ChatViewModel.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 23/02/26.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Combine
import FirebaseFirestore


class ChatViewModel: ObservableObject {
    let user: UserProfile
    let eventId: String?
    @Published var messages = [Message]()
    
    init(user: UserProfile, eventId: String? = nil) {
        self.user = user
        self.eventId = eventId
        fetchMessages()
    }
    
    func fetchMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore().collection("messages")
            .document(currentUid)
            .collection(user.id)
            .order(by: "timestamp", descending: false)
        
        query.addSnapshotListener { snapshot, error in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            var newMessages = changes.compactMap({ try? $0.document.data(as: Message.self) })
            
            for i in 0 ..< newMessages.count {
                let chatPartnerId = newMessages[i].chatPartnerId
                
                if chatPartnerId != currentUid {
                    newMessages[i].user = self.user
                }
            }
            
            self.messages.append(contentsOf: newMessages)
        }
    }
    
    func sendMessage(_ messageText: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let uid = user.id
        
        let currentUserRef = Firestore.firestore().collection("messages").document(currentUid).collection(uid).document()
        let receivingUserRef = Firestore.firestore().collection("messages").document(uid).collection(currentUid)
        let receivingRecentRef = Firestore.firestore().collection("messages").document(uid).collection("recent-messages")
        let currentRecentRef =  Firestore.firestore().collection("messages").document(currentUid).collection("recent-messages")
        
        let messageID = currentUserRef.documentID
        
        let data: [String: Any] = ["text": messageText,
                                   "id": messageID,
                                   "fromId": currentUid,
                                   "toId": uid,
                                   "eventId": eventId ?? "",
                                   "timestamp": Timestamp(date: Date())]
        
        let recipientData: [String: Any] = ["text": messageText,
                                            "id": messageID,
                                            "fromId": currentUid,
                                            "toId": uid,
                                            "eventId": eventId ?? "",
                                            "timestamp": Timestamp(date: Date())]
        
        currentUserRef.setData(data)
        currentRecentRef.document(uid).setData(data)

        receivingUserRef.document(messageID).setData(recipientData)
        receivingRecentRef.document(currentUid).setData(recipientData)
    }
    
}
