//
//  MetricsCollector.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import Foundation

protocol MetricsCollector {
    var startDateTime: Date { get }
    func startSession() -> Void
    func endSession(event: EventFullDetails) async throws -> Void
}
