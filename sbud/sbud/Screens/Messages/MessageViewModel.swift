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
    
    var currentUid: String { return Auth.auth().currentUser?.uid ?? "" }
    
    var isFromCurrentUser: Bool { return message.fromId == currentUid }
    
}

