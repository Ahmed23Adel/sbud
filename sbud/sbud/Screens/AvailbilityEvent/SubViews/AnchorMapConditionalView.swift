//
//  AnchorMapConditionalView.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI
import MapKit
internal import FirebaseFirestoreInternal
import FirebaseFirestore

struct AnchorMapConditionalView: View {
    let anchorAvailabilityEvents: [AnchorAvailabilityEvent]
    let anchorClusters: [AnchorCluster]
    let shouldShowIndividuals: Bool
    @Binding var cameraPosition: MapCameraPosition
    let onCameraChangeFunc: (MKCoordinateRegion) -> Void
    @EnvironmentObject private var coordinator: AvailabilityCoordinator
    
    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()

            if shouldShowIndividuals {
                AnchorsCollectioEventsView(anchorAvailabilityEvents: anchorAvailabilityEvents)

            } else {
                AnchorsCollectioClustersView(anchorClusters: anchorClusters)
            }

        }
        .environmentObject(coordinator)
        .onMapCameraChange { context in
            onCameraChangeFunc(context.region)
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()

        }
        .padding(.top, 32)
        .ignoresSafeArea()
    }
}

#Preview {
    @Previewable @State var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45.4384, longitude: 9.2196),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
//"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s"
    AnchorMapConditionalView(
        anchorAvailabilityEvents: [
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
                )
            )

        ],
        anchorClusters: [],
        shouldShowIndividuals: true,
        cameraPosition: $position,
        onCameraChangeFunc: { region in
        }
    )
}
