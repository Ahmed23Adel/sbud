//
//  IMetricsRepository.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//


import Foundation
import FirebaseFirestore

// MARK: - Protocol

protocol IMetricsRepository {
    func fetchMetrics(eventId: String) async throws -> [MetricsCollectedRun]
    func fetchSessionHistory(eventId: String) async throws -> [SessionHistoryEntry]
}

