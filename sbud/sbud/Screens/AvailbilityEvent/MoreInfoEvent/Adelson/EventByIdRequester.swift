//
//  EventByIdRequester.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import Foundation
import AdelsonAuthManager
import AdelsonApiCaller

class EventByIdRequester {

    func createApiCaller() -> AdelsonFirebaseApiCaller<EventFullDetails> {
        return AdelsonFirebaseApiCaller<EventFullDetails>()
    }

    func fetchEvent(eventId: String) async throws -> EventFullDetails {
        let apiCaller = createApiCaller()
        return try await apiCaller.callGet(
            url: "events/\(eventId)",
            queryParams: [:],
            config: AdelsonFirebaseAuthConfig.shared
        )
    }
}
