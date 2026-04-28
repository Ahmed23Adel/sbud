//
//  ViewModelCoordinatorAddNewEvent.swift
//  sbud
//
//  Created by ahmed on 31/03/2026.
//

import Foundation
@Observable
class ViewModelCoordinatorAddNewEvent {
    var currentStep = AddNewEventSteps.step1
    var newEventBuilder = NewEventBuilder()
    var isDismissed = false
    var isLoading = false

    func createEvent() {
        if !newEventBuilder.areFieldsValid() {
            newEventBuilder.generateErrorMsg()
            return
        }
        Task {
            isLoading = true
            if await newEventBuilder.sendRequest() {
                isDismissed = true
            }
            isLoading = false
        }
    }

    func moveToStep2() { currentStep = .step2 }
    func moveToStep1() { currentStep = .step1 }
}
