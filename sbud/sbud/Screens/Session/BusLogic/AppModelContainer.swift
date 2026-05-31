//
//  AppModelContainer.swift
//  sbud
//
//  Created by ahmed on 31/05/2026.
//

import SwiftData

/// The app's single shared `ModelContainer`.
///
/// Both the SwiftUI environment and `MetricsUploadRetryService` reference this
/// instance so they operate on the same persistent store.
///
/// **Adding a new SwiftData model:**
/// Register it in `allModels` — that's the only change needed.
enum AppModelContainer {

    // MARK: - Registered models

    /// All `@Model` types the app persists.
    /// Add new types here — nothing else needs to change.
    private static let allModels: [any PersistentModel.Type] = [
        LocalOnGoingSession.self,
        PendingMetricsUpload.self
    ]

    // MARK: - Shared instance

    static let shared: ModelContainer = {
        let schema = Schema(allModels)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Container failure is unrecoverable — crash loudly in debug, log in prod.
            fatalError("AppModelContainer: failed to create ModelContainer — \(error)")
        }
    }()
}
