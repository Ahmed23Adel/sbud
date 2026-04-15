//
//  NewEventBuilder.swift
//  sbud
//
//  Created by ahmed on 31/03/2026.
//

import Foundation

@Observable
class NewEventBuilder{
    // MARK: Step1
    // TODO: To be replaced with user profile image
    var coverImgURL: String = "https://images.unsplash.com/photo-1654110455429-cf322b40a906?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZSUyMHBpY3R1cmV8ZW58MHx8MHx8fDA%3D"
    var title: String = ""
    var activityType: ActivityType = .running
    var description: String = ""
    var activityExtraArgs = NewEventExtraArgsHoder()
    // MARK: Step2
    var dateLocationsHolder = MultipleDateLocationsHolder()
    var isEventPublic = true
    var joiningCondition: JoinCondition = .requestFromHost
    var eventCapacity = 150
    
    
    func areFieldsValid() -> Bool {
        if coverImgURL.count != 0 &&
            title.count != 0 &&
            description.count != 0 &&
            activityExtraArgs.areFieldsValid() &&
            dateLocationsHolder.areFieldsValid() &&
            eventCapacity > 0 {
            return true
        }
        return false
    }
    
    func generateErrorMsg(){
        var errorMsg = ""
        if title.count <= 0{
            errorMsg = "Event must have a title"
        }else if description.count <= 0 {
            errorMsg = "Please enter a valid description"
        } else if !activityExtraArgs.areFieldsValid() {
            errorMsg = "Performance targets are not valid"
        } else if !dateLocationsHolder.areFieldsValid(){
            errorMsg = "Non valid Date&Locations"
        } else if eventCapacity <= 0 {
            errorMsg = "Please enter a valid capacity"
        }
        PopUpGenerator.shared.show(msg: errorMsg, type: .error)
        
    }
    
    func sendRequest() async {
        let request = CreateNewEventRequest(
            activityDetails: activityExtraArgs.extraArgs.createEncodableRequest(),
            title: title,
            eventImage: coverImgURL,
            isPublic: isEventPublic,
            joiningCondition: joiningCondition,
            maxAllowedToJoin: eventCapacity,
            notes: description,
            dateLocations: dateLocationsHolder.lst)
        let requester = CreateNewEventRequester()
        do {
            let _ = try await requester.createNewEvent(requestParams: request)
        } catch {
            PopUpGenerator.shared.show(msg: "Error, please try again", type: .error)
        }
    }
}
