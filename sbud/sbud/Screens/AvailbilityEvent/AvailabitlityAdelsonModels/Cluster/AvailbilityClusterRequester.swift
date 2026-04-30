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

    func createApiCaller() -> AdelsonFirebaseApiCaller<AvailabitlityClusterResponse> {
        return AdelsonFirebaseApiCaller<AvailabitlityClusterResponse>()
    }

    func fetchClusters(
        requestParams: AvailabilityClusterModelRequest
    ) async throws -> AvailabitlityClusterResponse {
        let apicaller = createApiCaller()
        print("AdelsonFirebaseAuthConfig", AdelsonFirebaseAuthConfig.shared)
        return try await apicaller.callGet(
            url: "events/clusters",
            queryParams: requestParams.toDict(),
            config: AdelsonFirebaseAuthConfig.shared)
    }
}
