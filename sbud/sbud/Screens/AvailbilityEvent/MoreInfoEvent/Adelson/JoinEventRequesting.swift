//
//  JoinEventRequesting.swift
//  sbud
//

import Foundation

protocol JoinEventRequesting {
    func joinEvent(eventId: String) async throws -> JoinEventResponse
    func withdraw(eventId: String) async throws -> WithdrawResponse
    func leave(eventId: String) async throws -> LeaveResponse
    func getMyStatus(eventId: String) async throws -> MyStatusResponse
}

extension JoinEventRequester: JoinEventRequesting {}
