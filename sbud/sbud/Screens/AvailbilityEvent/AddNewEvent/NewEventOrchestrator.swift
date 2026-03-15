//
//  NewEventOrchestrator.swift
//  sbud
//
//  Created by ahmed on 14/03/2026.
//

import Foundation
import Combine

class NewEventOrchestrator: ObservableObject{
    @Published var title: String = ""
    @Published var eventImageURL: String = ""
    @Published var extraArgsHolder = NewEventExtraArgsHoder()
    @Published var dateLocationsHolder = MultipleDateLocationsHolder()
    @Published var isEventPublic = true
    @Published var joiningCondition: JoinCondition = .requestFromCreator
    @Published var maxAllowedToJoin = "150"
    @Published var notes = ""
    func updateEventImageURL(_ img: String){
        self.eventImageURL = img
    }
    
    
    func createRequestData() -> CreateNewEventRequest{
        return CreateNewEventRequest(
            activityDetails: extraArgsHolder.createRequest(),
            title: title,
            eventImage: eventImageURL,
            isPublic: isEventPublic,
            joiningCondition: joiningCondition,
            maxAllowedToJoin: Int(maxAllowedToJoin)!,
            notes: notes,
            dateLocations: dateLocationsHolder.lst.compactMap{ $0 }
            
        )
    }
    
    
    
    
}
