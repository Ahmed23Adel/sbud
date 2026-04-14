//
//  AnchorCluster.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

nonisolated class AnchorCluster: IAnchorCluster {
    nonisolated var cluster: any IAailabilityAggregate
    nonisolated var count: Int {
        cluster.count
    }

    init(cluster: any IAailabilityAggregate) {
        self.cluster = cluster
    }

    static func == (lhs: AnchorCluster, rhs: AnchorCluster) -> Bool {
        lhs.cluster.id == rhs.cluster.id
    }

}
