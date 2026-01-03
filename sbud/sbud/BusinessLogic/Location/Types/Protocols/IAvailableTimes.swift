//
//  IAvailableTimes.swift
//  sbud
//
//  Created by ahmed on 24/12/2025.
//

import Foundation
protocol IAvailableTimes: Identifiable, Identifiable, Equatable{
    var startTime: Date { get }
    var endTime: Date { get }
}

