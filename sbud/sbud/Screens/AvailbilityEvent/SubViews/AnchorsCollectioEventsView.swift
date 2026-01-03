//
//  AnchorsCollectioEventsView.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI
import MapKit
internal import FirebaseFirestoreInternal

struct AnchorsCollectioClustersView: MapContent {
    let anchorClusters: [AnchorCluster]
    
    var body: some MapContent {
        ForEach(anchorClusters) { cluster in
            Annotation(
                "\(cluster.count) available",
                coordinate: CLLocationCoordinate2D(
                    latitude: cluster.cluster.location.latitude,
                    longitude: cluster.cluster.location.longitude
                )
            ) {
                
                ClusterAnnotationView(count: cluster.count)
            }
        }
    }
}

#Preview {
    Map {
        AnchorsCollectioClustersView(anchorClusters: [
            AnchorCluster(
                cluster: AvailabiltiyAggregate(
                    id: "",
                    count: 4,
                    geohash: "",
                    location: GeoPoint(latitude: 4.3,
                                       longitude: 4.5),
                    precision: 5
            ))
        ])
    }
}
