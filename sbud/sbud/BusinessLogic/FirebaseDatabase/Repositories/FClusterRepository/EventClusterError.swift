//
//  EventClusterError.swift
//  sbud
//
//  Created by ahmed on 25/01/2026.
//

import Foundation

enum EventClusterError: Error {
    case invalidResponse
    case functionCallFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .functionCallFailed(let error):
            return "Function call failed: \(error.localizedDescription)"
        }
    }
}
