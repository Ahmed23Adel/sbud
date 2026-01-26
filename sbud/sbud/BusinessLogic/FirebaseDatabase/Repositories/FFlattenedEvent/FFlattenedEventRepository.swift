//
//  FFlattenedEventRepository.swift
//  sbud
//
//  Created by ahmed on 26/01/2026.
//

import Foundation
import FirebaseFunctions

class FFlattenedEventRepository: ICloudFunctionRepository{
    typealias Constants = FFlattenedEventConstants
    typealias T = FFlattenedEvent
    var funcName = "getFlattenedEventsInBounds"
    private let functions: Functions
    
    init(functions: Functions = Functions.functions()) {
        self.functions = functions
    }
    
    func fetch(_ request: FlattenedEventsRequest) async throws -> FFlattenedEventsResponse {
        let callable = functions.httpsCallable(funcName)
        let parameters = request.toParameters()
        do {
            let result = try await callable.call(parameters)
            guard let data = result.data as? [String: Any] else {
                throw EventClusterError.invalidResponse
            }
            
            // Use dictionary initializer instead of JSONDecoder
            let response = try FFlattenedEventsResponse(from: data)
            
            return response
            
        } catch {
            throw FFlattenedEventClusterError.functionCallFailed(error)
        }
    }
}
