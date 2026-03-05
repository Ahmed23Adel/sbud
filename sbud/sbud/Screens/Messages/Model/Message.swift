//
//  Message.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 23/02/26.
//

import FirebaseFirestore
import Firebase
import FirebaseAuth

struct Message: Identifiable, Hashable, Decodable {
    let id: String
    let fromId: String
    let toId: String
    let timestamp: Timestamp
    let text: String
    
    var user: User?
    
    var chatPartnerId: String { return fromId == Auth.auth().currentUser?.uid ? toId : fromId }

}
