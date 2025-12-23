//
//  IAnchorAvailabilityEvent.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

protocol IAnchorAvailabilityEvent: Identifiable, Identifiable, Equatable{
    var availabilityEvent: any IAvailabilityEvent { get }
}
