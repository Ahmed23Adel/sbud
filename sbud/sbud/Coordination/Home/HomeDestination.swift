//
//  HomeDestination.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import Foundation
//  Scaffold for the Home tab coordinator.
//  Add routes, push destinations, and sheet types here as the tab is built out.
//  Uses the same pattern as AvailabilityCoordinator.
//
 
import Foundation
import SwiftUI
import Combine
// MARK: - Route Types (scaffold — add cases as needed)
 
enum HomeDestination: Hashable, Equatable {
    // e.g. case eventDetail(eventId: String)
}
 
enum HomeSheet: Identifiable {
    // e.g. case createPost
 
    var id: String {
        // return a unique string per case
        return "placeholder"
    }
}
