//
//  UpdateEventRequester.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import Foundation
import AdelsonAuthManager
import AdelsonApiCaller
internal import Alamofire

class UpdateEventRequester {

    func createApiCaller() -> AdelsonFirebaseApiCaller<EmptyResponse> {
        return AdelsonFirebaseApiCaller<EmptyResponse>()
    }

    func updateEvent(eventId: String, requestParams: UpdateEventRequest) async throws {
        let apiCaller = createApiCaller()
        _ = try await apiCaller.call(
            url: "events/\(eventId)",
            params: requestParams,
            method: .put,
            config: AdelsonFirebaseAuthConfig.shared
        )
    }
}
