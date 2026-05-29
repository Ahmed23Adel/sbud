//
//  DeleteEventRequester.swift
//  sbud
//
//  Created by ahmed on 25/05/2026.
//

import Foundation
import AdelsonAuthManager
import AdelsonApiCaller

class DeleteEventRequester {

    func createApiCaller() -> AdelsonFirebaseApiCaller<EmptyResponse> {
        return AdelsonFirebaseApiCaller<EmptyResponse>()
    }

    func deleteEvent(eventId: String) async throws {
        let apiCaller = createApiCaller()
        _ = try await apiCaller.call(
            url: "events/\(eventId)",
            params: EmptyRequest(),
            method: .delete,
            config: AdelsonFirebaseAuthConfig.shared
        )
    }
}

nonisolated struct EmptyRequest: Codable {}
nonisolated struct EmptyResponse: Decodable {
    
}
