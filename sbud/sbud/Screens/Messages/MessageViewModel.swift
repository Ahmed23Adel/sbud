//
//  MessageViewModel.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 04/05/26.
//


//
//  MessageViewModel.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 23/02/26.
//

import Firebase
import FirebaseAuth

struct MessageViewModel {
    let message: Message
    
    let currentUid: String

    init(message: Message, currentUid: String = Auth.auth().currentUser?.uid ?? "") {
        self.message = message
        self.currentUid = currentUid
    }

    var isFromCurrentUser: Bool { return message.fromId == currentUid }
}
