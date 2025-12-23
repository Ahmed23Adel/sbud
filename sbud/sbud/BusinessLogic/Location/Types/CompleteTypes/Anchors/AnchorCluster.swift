//
//  AnchorCluster.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

class AnchorCluster: IAnchorCluster{
    var cluster: any IAailabilityAggregate
    
    init(cluster: any IAailabilityAggregate){
        self.cluster = cluster
    }
    static func == (lhs: AnchorCluster, rhs: AnchorCluster) -> Bool {
        lhs.cluster.id == rhs.cluster.id
    }
    
    
}
