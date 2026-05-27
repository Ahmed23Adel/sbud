//
//  ChatViewModel.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 04/05/26.
//


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
    let eventId: String
    @Published var messages = [Message]()
    
    init(user: UserProfile, eventId: String) {
        self.user = user
        self.eventId = eventId
        fetchMessages()
    }
    
    func fetchMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let chatRoomId = "\(user.id)_\(eventId)"
        
        let query = Firestore.firestore().collection("messages")
            .document(currentUid)
            .collection(chatRoomId)
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
    
    func markMessagesAsRead() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let chatRoomIdForCurrent = "\(user.id)_\(eventId)"
        
        let currentRecentRef = Firestore.firestore()
            .collection("messages")
            .document(currentUid)
            .collection("recent-messages")
            .document(chatRoomIdForCurrent)
        
        //merge piu sicuro
        currentRecentRef.setData(["isRead": true], merge: true) { error in
            if let error = error {
                print("❌ Errore aggiornamento lettura: \(error.localizedDescription)")
                
            }
        }
    }
    
    func sendMessage(_ messageText: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let uid = user.id
        
        let chatRoomIdForCurrent = "\(uid)_\(eventId)"
        let chatRoomIdForRecipient = "\(currentUid)_\(eventId)"
        
        let currentUserRef = Firestore.firestore().collection("messages").document(currentUid).collection(chatRoomIdForCurrent).document()
        let receivingUserRef = Firestore.firestore().collection("messages").document(uid).collection(chatRoomIdForRecipient)
        
        let currentRecentRef =  Firestore.firestore().collection("messages").document(currentUid).collection("recent-messages")
        let receivingRecentRef = Firestore.firestore().collection("messages").document(uid).collection("recent-messages")
        
        let messageID = currentUserRef.documentID
        
        let data: [String: Any] = ["text": messageText,
                                   "id": messageID,
                                   "fromId": currentUid,
                                   "toId": uid,
                                   "eventId": eventId,
                                   "timestamp": Timestamp(date: Date()),
                                   "isRead": true]
        
        let recipientData: [String: Any] = ["text": messageText,
                                            "id": messageID,
                                            "fromId": currentUid,
                                            "toId": uid,
                                            "eventId": eventId,
                                            "timestamp": Timestamp(date: Date()),
                                            "isRead": false]
        
        
        currentUserRef.setData(data) { error in
            if let error = error { print("❌ Error currentUserRef: \(error.localizedDescription)") }
        }
        
        currentRecentRef.document(chatRoomIdForCurrent).setData(data) { error in
            if let error = error { print(" Error currentRecentRef: \(error.localizedDescription)") }
        }

        
        receivingUserRef.document(messageID).setData(recipientData) { error in
            if let error = error { print(" Error receivingUserRef: \(error.localizedDescription)") }
        }
        
        receivingRecentRef.document(chatRoomIdForRecipient).setData(recipientData) { error in
            if let error = error {
                print("❌ Error receivingRecentRef: \(error.localizedDescription)")
            } else {
                print("✅ SUCCESS! ")
            }
        }
    }
    
}
