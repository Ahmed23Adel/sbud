//
//  NewEventOrchestrator.swift
//  sbud
//
//  Created by ahmed on 14/03/2026.
//

import Foundation
import Combine

class NewEventOrchestrator: ObservableObject{
    @Published var eventImageURL: String = ""
    @Published var extraArgsHolder = NewEventExtraArgsHoder()
    @Published var dateLocationsHolder = MultipleDateLocationsHolder()
    
    func updateEventImageURL(_ img: String){
        self.eventImageURL = img
    }
    
    
    
    
    
}
