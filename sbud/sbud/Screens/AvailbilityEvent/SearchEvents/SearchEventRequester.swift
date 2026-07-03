//
//  SearchEventRequester.swift
//  sbud
//
//  Created by ahmed on 26/05/2026.
//

import Foundation
import AdelsonApiCaller
import AdelsonAuthManager

nonisolated class SearchEventRequester {

    nonisolated func createApiCaller() -> AdelsonFirebaseApiCaller<SearchEventResponse> {
        return AdelsonFirebaseApiCaller<SearchEventResponse>()
    }

    nonisolated func search(requestType: SearchEventRequestType) async throws -> SearchEventResponse {
        let apiCaller = createApiCaller()
        return try await apiCaller.callGet(
            url: requestType.endpoint,
            queryParams: requestType.toDict(),
            config: AdelsonFirebaseAuthConfig.shared
        )
    }
}
