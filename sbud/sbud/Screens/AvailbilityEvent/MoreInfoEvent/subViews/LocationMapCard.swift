//
//  LocationMapCard.swift
//  sbud
//
//  Created by ahmed on 05/02/2026.
//
import SwiftUI
import FirebaseFirestore
import MapKit

struct LocationMapCard: View {
    var event: AvailabilityEvent
    @State private var showFullMap = false
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: event.geoPoint.latitude, longitude: event.geoPoint.longitude)
    }
    var cameraPosition: MapCameraPosition {
        .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    var body: some View {
        VStack {
            Map(position: .constant(cameraPosition)) {
                Annotation("", coordinate: coordinate) {
                    IndividualAnnotationView(event: event.convertToAnchor(), allowNavigation: false)
                }
            }
            .frame(width: UIConstants.bigCardWidth, height: UIConstants.bigCardHeight)
            .cornerRadius(UIConstants.cornerRadius)
            .allowsHitTesting(false)
        }
        .contentShape(Rectangle())  // Make entire area tappable
        .onTapGesture {
            showFullMap = true
        }
        .popUp()
        .sheet(isPresented: $showFullMap) {
            FullMapView(event: event)
        }
    }
}

struct FullMapView: View {
    let event: AvailabilityEvent
    @Environment(\.dismiss) var dismiss
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: event.geoPoint.latitude, longitude: event.geoPoint.longitude)
    }
    
    var cameraPosition: MapCameraPosition {
        .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        NavigationView {
            Map(position: .constant(cameraPosition)) {
                Annotation("", coordinate: coordinate) {
                    IndividualAnnotationView(event: event.convertToAnchor(), allowNavigation: false)
                }
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: openInMaps) {
                        Image(systemName: "map.fill")
                    }
                }
            }
        }
    }
    
    private func openInMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = "Suggested Location"
        mapItem.openInMaps(launchOptions: nil)
    }
}

#Preview {
    LocationMapCard(
        event: AvailabilityEvent(
            id: "cf5f3e6b-a62b-4c43-85f5-e47ca287419f",
            eventId: "xN6ncT0Foa0UdFy06GSL",
            geoPoint: GeoPoint(latitude: 43.2, longitude: 9.3),
            dateLocationId: "milano_centro_001",
            activityType: "Coffee",
            startDateTime: Date().addingTimeInterval(3600),
            endDateTime: Date().addingTimeInterval(7200),
            createdAt: Date(),
            g: GeoLocation(geopoint: Coordinate(latitude: 43.2, longitude: 9.3), geohash: "u0ndx37j"),
            isDateConfirmed: true,
            isLocationConfirmed: false,
            isPublic: true,
            eventImage: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s",
            creatorName: "Ahmed"
        )
    )
}
