//
//  MapAnnotationType.swift
//  sbud
//
//  Created by ahmed on 22/12/2025.
//

import Foundation

enum MapAnnotationType: Identifiable, Equatable{
    case cluster(ClusterAnnotation)
    case individual(AvailabilityEvent)
    
    var id: String{
        switch self{
        case .cluster(let cluster):
            return "cluster_\(cluster.id)"
        case .individual(let availabilityEvent):
            return "individual_\(availabilityEvent.id)"
        }
    }
    
    static func  == (lfs: MapAnnotationType, rhs: MapAnnotationType) -> Bool{
        lfs.id == rhs.id
    }
}
