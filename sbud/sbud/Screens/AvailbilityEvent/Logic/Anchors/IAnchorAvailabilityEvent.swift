//
//  IAnchorAvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

protocol IAnchorAvailabilityEvent: Identifiable, Equatable {
    var event: any IAvailabilityEvent { get }
}
