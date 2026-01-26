//
//  AnchorsCollectioView.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI
import MapKit
internal import FirebaseFirestoreInternal

struct AnchorsCollectioEventsView: MapContent {
    let anchorAvailabilityEvents: [AnchorAvailabilityEvent]
    
    var body: some MapContent {
        ForEach(anchorAvailabilityEvents) { event in
            Annotation(
                "",
                coordinate: CLLocationCoordinate2D(
                    latitude: event.event.geoPoint.latitude,
                    longitude: event.event.geoPoint.longitude
                )
            ) {
                IndividualAnnotationView(event: event)
            }
        }
    }
}

#Preview {
    Map {
        AnchorsCollectioEventsView(anchorAvailabilityEvents: [
            AnchorAvailabilityEvent(
                event: AvailabilityEvent(
                    id: "cf5f3e6b-a62b-4c43-85f5-e47ca287419f",
                    geohash: "u0nd3zc8",
                    geoPoint: GeoPoint(latitude: 45.43817043216585, longitude: 9.219661393563264),
                    ownerProfilePicture: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s"))
        ])
    }
}
