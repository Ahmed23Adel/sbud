//
//  EventClusterRepository.swift
//  sbud
//
//  Created by ahmed on 25/01/2026.
//

import Foundation
import FirebaseFunctions

class EventClusterRepository: ICloudFunctionRepository{
    typealias Constants = EventClusterConstants
    typealias T = EventCluster
    var funcName = "getAvailableEventClusters"
    private let functions: Functions
    
    init(functions: Functions = Functions.functions()) {
        self.functions = functions
    }
    
    func fetch(_ request: EventClusterRequest) async throws -> EventClusterResponse {
        let callable = functions.httpsCallable(funcName)
        let parameters = request.toParameters()
        print("params", parameters)
        do {
            let result = try await callable.call(parameters)
            guard let data = result.data as? [String: Any] else {
                throw EventClusterError.invalidResponse
            }
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let response = try JSONDecoder().decode(EventClusterResponse.self, from: jsonData)
            print("jsonData", response)
            return response
            
        } catch {
            print("error", error)
            throw EventClusterError.functionCallFailed(error)
        }
    }
}
