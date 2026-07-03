//
//  ViewModelCoordinatorAddNewEvent.swift
//  sbud
//
//  Created by ahmed on 31/03/2026.
//

import Foundation
import FirebaseAnalytics

@Observable
class ViewModelCoordinatorAddNewEvent {
    var currentStep = AddNewEventSteps.step1
    var newEventBuilder = NewEventBuilder()
    var isDismissed = false
    var isLoading = false

    private let eventService: CreateEventRequesting

    init(eventService: CreateEventRequesting = CreateNewEventRequester()) {
        self.eventService = eventService
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "CreateEvent"])
    }

    func createEvent() {
        guard newEventBuilder.areFieldsValid() else {
            newEventBuilder.generateErrorMsg()
            return
        }
        Task {
            await MainActor.run { isLoading = true }
            do {
                _ = try await eventService.createNewEvent(requestParams: newEventBuilder.buildRequest())
                await MainActor.run { isDismissed = true }
            } catch {
                PopUpGenerator.shared.show(msg: "Error, please try again", type: .error)
            }
            await MainActor.run { isLoading = false }
        }
    }

    func moveToStep2() { currentStep = .step2 }
    func moveToStep1() { currentStep = .step1 }
}
