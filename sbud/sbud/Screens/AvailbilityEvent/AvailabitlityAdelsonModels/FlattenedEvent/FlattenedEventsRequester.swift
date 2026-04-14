//
//  AvailbilityRequester.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import AdelsonApiCaller
import AdelsonAuthManager

// nonisolated is safe when:
// no stored mutable state
// just methods that call an API
// no shared variables between calls
// if not, If two tasks call func simultaneously, Swift guarantees no data race because everything is serialized through the main actor. otherwisw, it's your responsibility to guard it

nonisolated class FlattenedEventsRequester {

    nonisolated func createApiCaller() -> AdelsonFirebaseApiCaller<FlattenedEventResponse> {
        return AdelsonFirebaseApiCaller<FlattenedEventResponse>()
    }

    nonisolated func fetchIndividuals(requestParams: FlattenedEventsRequest) async throws -> FlattenedEventResponse {
        let apicaller = createApiCaller()
        return try await apicaller.callGet(
            url: "events/flattenedevents",
            queryParams: requestParams.toDict(),
            config: AdelsonFirebaseAuthConfig.shared)
    }
}
