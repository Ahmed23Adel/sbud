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
    @EnvironmentObject private var coordinator: AvailabilityCoordinator
    var body: some MapContent {
        ForEach(anchorAvailabilityEvents) { event in
            Annotation(
                "",
                coordinate: CLLocationCoordinate2D(
                    latitude: event.event.geoPoint.latitude,
                    longitude: event.event.geoPoint.longitude
                )
            ) {
                IndividualAnnotationView(event: event, allowNavigation: true)
                    .environmentObject(coordinator)
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
                    geoPoint: GeoPoint(latitude: 45.4642, longitude: 9.1900),
                    dateLocationId: "milano_centro_001",
                    activityType: "Coffee",
                    startDateTime: Date().addingTimeInterval(3600), // 1 hour from now
                    endDateTime: Date().addingTimeInterval(7200),   // 2 hours from now
                    createdAt: Date(),
                    g: GeoLocation(geopoint: Coordinate(latitude: 43, longitude: 9.4), geohash: "u0ndx37j"),
                    isDateConfirmed: true,
                    isLocationConfirmed: false,
                    isPublic: true,
                    eventImage: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s",
                    creatorName: "Ahmed"
                ))
        ])
    }
}

