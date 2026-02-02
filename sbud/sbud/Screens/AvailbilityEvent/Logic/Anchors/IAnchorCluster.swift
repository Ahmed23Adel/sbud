//
//  IAnchorCluster.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

protocol IAnchorCluster: Identifiable, Equatable {
    var cluster: any IAailabilityAggregate { get }
}
