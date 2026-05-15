//
//  ViewModeOwnerSession.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import Foundation

@Observable
class ViewModelOwnerSession{
    let eventId: String
    
    init(eventId: String){
        self.eventId = eventId
    }
}
