//
//  ClusterAnnotation.swift
//  sbud
//
//  Created by ahmed on 22/12/2025.
//

import Foundation
import CoreLocation

struct ClusterAnnotation: Identifiable, Equatable{
    let id: String
    let coordinate: CLLocationCoordinate2D
    let count: Int
    let geohash: String
    let precision: Int
    
    static func == (lhs: ClusterAnnotation, rhs: ClusterAnnotation) -> Bool{
        lhs.id == rhs.id
    }
}
