//
//  NewEventBuilder.swift
//  sbud
//
//  Created by ahmed on 31/03/2026.
//

import Foundation
import OSLog

@Observable
class NewEventBuilder{
    // MARK: Step1
    // TODO: To be replaced with user profile image
    var coverImgURL: String = (ProfileManager.shared.getLocalProfile()?.profileImageUrl!)!
    var title: String = ""
    var activityType: ActivityType = .running
    var description: String = ""
    var activityExtraArgs = ExtraArgsHolder()
    // MARK: Step2
    var dateLocationsHolder = MultipleDateLocationsHolder()
    var isEventPublic = true
    var joiningCondition: JoinCondition = .requestFromHost
    var eventCapacity = 150
    let logger = Logger(subsystem: "sBud", category: "NewEventBuilder")
    
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
    
    func sendRequest() async  -> Bool{
        let request = CreateNewEventRequest(
            activityDetails: activityExtraArgs.extraArgs,
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
            return true
        } catch {
            PopUpGenerator.shared.show(msg: "Error, please try again", type: .error)
            logger.error("Error with creating event: \(error.localizedDescription)")
            return false
        }
    }
}
