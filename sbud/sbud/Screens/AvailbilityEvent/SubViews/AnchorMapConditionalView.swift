//
//  AnchorMapConditionalView.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI
import MapKit
internal import FirebaseFirestoreInternal

struct AnchorMapConditionalView: View {
    let anchorAvailabilityEvents: [AnchorAvailabilityEvent]
    let anchorClusters: [AnchorCluster]
    let shouldShowIndividuals: Bool
    @Binding var cameraPosition: MapCameraPosition
    let onCameraChangeFunc: (MKCoordinateRegion) -> Void
    
    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            
            if shouldShowIndividuals{
                AnchorsCollectioEventsView(anchorAvailabilityEvents: anchorAvailabilityEvents)
                
            } else{
                AnchorsCollectioClustersView(anchorClusters: anchorClusters)
            }
            
        }
        .onMapCameraChange { context in
            onCameraChangeFunc(context.region)
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
            
        }
        .safeAreaPadding(.top, 40)
    }
}

#Preview {
    @Previewable @State var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45.4384, longitude: 9.2196),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    AnchorMapConditionalView(
        anchorAvailabilityEvents: [
            AnchorAvailabilityEvent(
                event: AvailabilityEvent(
                    id: "cf5f3e6b-a62b-4c43-85f5-e47ca287419f",
                    geoPoint: GeoPoint(latitude: 45.43817043216585, longitude: 9.219661393563264),
                    ownerProfilePicture: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s"
                )
            )
        ],
        anchorClusters: [],
        shouldShowIndividuals: true,
        cameraPosition: $position,
        onCameraChangeFunc: { region in
            print("Camera changed to: \(region.center)")
        }
    )
}
