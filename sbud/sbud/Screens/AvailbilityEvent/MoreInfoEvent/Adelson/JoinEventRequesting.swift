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
    func getPendingQueue(eventId: String) async throws -> JoinQueueResponse
    func respondToRequest(eventId: String, requesterId: String, accept: Bool) async throws -> JoinRespondResponse
}

extension JoinEventRequester: JoinEventRequesting {}
