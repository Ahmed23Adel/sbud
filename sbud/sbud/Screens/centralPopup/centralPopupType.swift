//
//  centralPopupType.swift
//  sbud
//
//  Created by ahmed on 04/02/2026.
//

import Foundation
import SwiftUI

enum centralPopupType {
    case notification, warning, error, information
    
    var themeColor: Color {
        switch self {
        case .warning: return .yellow
        case .error: return .red
        default: return .green 
        }
    }
    
    var animationName: String {
        switch self {
        case .notification: return "ring"
        case .warning: return "warning"
        case .error: return "alert"
        case .information: return "speaker"
        }
    }
}
