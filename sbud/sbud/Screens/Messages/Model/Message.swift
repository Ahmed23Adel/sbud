//
//  Message.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 04/05/26.
//


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
    
    var eventId: String?
    var isRead: Bool? //to show notifications of unread messages
    
    var user: UserProfile?
    
    var chatPartnerId: String { return fromId == Auth.auth().currentUser?.uid ? toId : fromId }

    // Equatable & Hashable Conformance
    
    // same ID =equal message
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    //hash generation with id
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
