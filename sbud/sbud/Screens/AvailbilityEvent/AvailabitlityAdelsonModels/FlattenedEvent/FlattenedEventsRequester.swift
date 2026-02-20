//
//  AvailbilityRequester.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import AdelsonApiCaller
import AdelsonAuthManager

class FlattenedEventsRequester {

    nonisolated func createApiCaller() -> AdelsonFirebaseApiCaller<FlattenedEventResponse> {
        return AdelsonFirebaseApiCaller<FlattenedEventResponse>()
    }

    nonisolated func fetchIndividuals(requestParams: FlattenedEventsRequest) async throws -> FlattenedEventResponse {
        let apicaller = createApiCaller()
        print("FlattenedParams", requestParams.toDict())
        return try await apicaller.callGet(
            url: "events/flattenedevents",
            queryParams: requestParams.toDict(),
            config: AdelsonFirebaseAuthConfig.shared)
    }
}
