//
//  PaginatedFlattenedEventsRequester.swift
//  sbud
//
//  Created by ahmed on 08/02/2026.
//

import Foundation
import AdelsonApiCaller
import AdelsonAuthManager

class PaginatedFlattenedEventsRequester {

    nonisolated func createApiCaller() -> AdelsonFirebaseApiCaller<PaginatedEventDetailsResponse> {
        return AdelsonFirebaseApiCaller<PaginatedEventDetailsResponse>()
    }

    nonisolated func fetchEvents(requestParams: PaginatedFlattenedEventsRequest) async throws -> PaginatedEventDetailsResponse {
        let apicaller = createApiCaller()
        return try await apicaller.callGet(
            url: "events/flattenedevents/paginated",
            queryParams: requestParams.toDict(),
            config: AdelsonFirebaseAuthConfig.shared)
    }
}
