//
//  CreateEventRequesting.swift
//  sbud
//

import Foundation

protocol CreateEventRequesting {
    func createNewEvent(requestParams: CreateNewEventRequest) async throws -> CreateNewEventResponse
}

extension CreateNewEventRequester: CreateEventRequesting {}
