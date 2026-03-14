//
//  CreateNewEventRequester.swift
//  sbud
//
//  Created by ahmed on 11/03/2026.
//

import Foundation
import AdelsonAuthManager
import AdelsonApiCaller

class CreateNewEventRequester {

    func createApiCaller() -> AdelsonFirebaseApiCaller<CreateNewEventResponse> {
        return AdelsonFirebaseApiCaller<CreateNewEventResponse>()
    }

    func fetchClusters(
        requestParams: CreateNewEventRequest
    ) async throws -> CreateNewEventResponse {
        let apicaller = createApiCaller()
        return try await apicaller.call(
            url: "events",
            params: requestParams,
            method: .post,
            config: AdelsonFirebaseAuthConfig.shared)
    }
}
