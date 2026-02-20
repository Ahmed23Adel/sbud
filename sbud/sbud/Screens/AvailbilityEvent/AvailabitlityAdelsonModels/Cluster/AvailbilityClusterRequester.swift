//
//  AvailabitlityRequester.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import AdelsonApiCaller
import AdelsonAuthManager

class AvailbilityClusterRequester {

    nonisolated func createApiCaller() -> AdelsonFirebaseApiCaller<AvailabitlityClusterResponse> {
        return AdelsonFirebaseApiCaller<AvailabitlityClusterResponse>()
    }

    nonisolated func fetchClusters(
        requestParams: AvailabilityClusterModelRequest
    ) async throws -> AvailabitlityClusterResponse {
        let apicaller = createApiCaller()
        print("ClusterParams", requestParams.toDict())
        return try await apicaller.callGet(
            url: "events/clusters",
            queryParams: requestParams.toDict(),
            config: AdelsonFirebaseAuthConfig.shared)
    }
}
