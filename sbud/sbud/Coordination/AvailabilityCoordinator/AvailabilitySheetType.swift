//
//  AvailabilitySheetType.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import Foundation

enum AvailabilitySheetType: Identifiable {
    case filter
    
    
    var id: String {
        switch self {
        case .filter: return "filter"
        }
    }
}
