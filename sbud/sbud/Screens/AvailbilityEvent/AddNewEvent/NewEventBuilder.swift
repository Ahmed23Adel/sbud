//
//  NewEventBuilder.swift
//  sbud
//
//  Created by ahmed on 31/03/2026.
//

import Foundation
import OSLog

@Observable
class NewEventBuilder {
    // MARK: Step 1
    var coverImgURL: String = ProfileManager.shared.getLocalProfile()?.profileImageUrl ?? ""
    var title: String = ""
    var activityType: ActivityType = .running
    var description: String = ""
    var activityExtraArgs = ExtraArgsHolder()
    // MARK: Step 2
    var dateLocationsHolder = MultipleDateLocationsHolder()
    var isEventPublic = true
    var joiningCondition: JoinCondition = .requestFromHost
    var eventCapacity = 150
    let logger = Logger(subsystem: "sBud", category: "NewEventBuilder")

    // MARK: - Validation

    func areFieldsValid() -> Bool {
        !coverImgURL.isEmpty &&
        !title.isEmpty &&
        !description.isEmpty &&
        activityExtraArgs.areFieldsValid() &&
        dateLocationsHolder.areFieldsValid() &&
        eventCapacity > 0
    }

    /// Returns the first validation failure message, or nil when all fields are valid.
    /// Use this instead of intercepting PopUpGenerator in tests.
    var validationErrorMessage: String? {
        if coverImgURL.isEmpty    { return "Event image is required" }
        if title.isEmpty          { return "Event must have a title" }
        if description.isEmpty    { return "Please enter a valid description" }
        if !activityExtraArgs.areFieldsValid() { return "Performance targets are not valid" }
        if !dateLocationsHolder.areFieldsValid() { return "Non valid Date&Locations" }
        if eventCapacity <= 0     { return "Please enter a valid capacity" }
        return nil
    }

    func generateErrorMsg() {
        PopUpGenerator.shared.show(
            msg: validationErrorMessage ?? "",
            type: .error
        )
    }

    /// Builds the network request from current state. Pure — no side effects.
    func buildRequest() -> CreateNewEventRequest {
        CreateNewEventRequest(
            activityDetails: activityExtraArgs.extraArgs,
            title: title,
            eventImage: coverImgURL,
            isPublic: isEventPublic,
            joiningCondition: joiningCondition,
            maxAllowedToJoin: eventCapacity,
            notes: description,
            dateLocations: dateLocationsHolder.lst
        )
    }

    // sendRequest is kept for backward compatibility but now delegates to buildRequest.
    func sendRequest() async -> Bool {
        let requester = CreateNewEventRequester()
        do {
            _ = try await requester.createNewEvent(requestParams: buildRequest())
            return true
        } catch {
            PopUpGenerator.shared.show(msg: "Error, please try again", type: .error)
            logger.error("Error with creating event: \(error.localizedDescription)")
            return false
        }
    }
}
