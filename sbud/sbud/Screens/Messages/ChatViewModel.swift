//
//  ChatViewModel.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 29/12/25.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import Combine
import FirebaseFirestore
/*
class ChatViewModel: ObservableObject{
    let user: User
    @Published var messages = [Message]()
    
    init(user: User) {
        self.user = user
        fetchMessages()
    }
    
    func fetchMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let query = Firestore.firestore().collection("messages")
            .document(currentUid)
            .collection(user.uid)// i have to change in id with custum user
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
        let uid = user.uid // i have to change in id with custum user
        
        let currentUserRef = Firestore.firestore().collection("messages").document(currentUid).collection(uid).document()
        let receivingUserRef = Firestore.firestore().collection("messages").document(uid).collection(currentUid)
        let receivingRecentRef = Firestore.firestore().collection("messages").document(uid).collection("recent-messages")
        let currentRecentRef =  Firestore.firestore().collection("messages").document(currentUid).collection("recent-messages")
        
        let messageID = currentUserRef.documentID
        
        let data: [String: Any] = ["text": messageText,
                                   "id": messageID,
                                   "fromId": currentUid,
                                   "toId": uid,
                                   "timestamp": Timestamp(date: Date())]
        
        let recipientData: [String: Any] = ["text": messageText,
                                            "id": messageID,
                                            "fromId": currentUid,
                                            "toId": uid,
                                            "timestamp": Timestamp(date: Date())]
        
        currentUserRef.setData(data)
        currentRecentRef.document(uid).setData(data)

        receivingUserRef.document(messageID).setData(recipientData)
        receivingRecentRef.document(currentUid).setData(recipientData)
    }
    
}

*/
