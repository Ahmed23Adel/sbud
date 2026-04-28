//
//  LocationMapCard.swift
//  sbud
//
//  Created by ahmed on 05/02/2026.
//
import SwiftUI
import FirebaseFirestore
import MapKit

// MARK: - Main Card

struct LocationMapCard: View {
    var dateLocations: [DateLocationEntry]
    @State private var selectedEntry: DateLocationEntry? = nil

    var body: some View {
        VStack(spacing: 12) {
            ForEach(dateLocations, id: \.id) { entry in
                DateLocationRow(entry: entry)
                    .onTapGesture {
                        selectedEntry = entry
                    }
            }
        }
        .sheet(item: $selectedEntry) { entry in
            FullMapView(entry: entry)
        }
    }
}

// MARK: - Single Row

struct DateLocationRow: View {
    let entry: DateLocationEntry

    private var coordinates: [CLLocationCoordinate2D] {
        entry.locations.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
    }

    private var cameraPosition: MapCameraPosition {
        guard !coordinates.isEmpty else { return .automatic }
        if coordinates.count == 1 {
            return .region(MKCoordinateRegion(
                center: coordinates[0],
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lons.min()! + lons.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (lats.max()! - lats.min()!) * 1.5 + 0.005,
            longitudeDelta: (lons.max()! - lons.min()!) * 1.5 + 0.005
        )
        return .region(MKCoordinateRegion(center: center, span: span))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // — Header
            HStack(alignment: .top, spacing: 16) {

                // Start datetime
                VStack(alignment: .leading, spacing: 2) {
                    Text("From")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(entry.startDateTime.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0))
                    Text(entry.startDateTime.formatted(date: .omitted, time: .shortened))
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                }

                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 20)

                // End datetime
                VStack(alignment: .leading, spacing: 2) {
                    Text("To")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(entry.endDateTime.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0))
                    Text(entry.endDateTime.formatted(date: .omitted, time: .shortened))
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                }

                Spacer()

                // Location count badge
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                    Text("\(entry.locations.count)")
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0).opacity(0.12)
                )
                .clipShape(Capsule())
            }
            .padding(.horizontal)
            .padding(.top, 14)
            .padding(.bottom, 10)

            // — Mini map
            Map(position: .constant(cameraPosition)) {
                ForEach(Array(coordinates.enumerated()), id: \.offset) { index, coord in
                    Annotation("", coordinate: coord) {
                        MapPinView(index: index + 1)
                    }
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius - 2))
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity)
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .contentShape(Rectangle())
    }
}

// MARK: - Pin View

struct MapPinView: View {
    let index: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0))
                .frame(width: 28, height: 28)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            Text("\(index)")
                .font(.caption.weight(.bold))
                .foregroundColor(.black)
        }
    }
}

// MARK: - Full Map Sheet

struct FullMapView: View {
    let entry: DateLocationEntry
    @Environment(\.dismiss) var dismiss

    private var coordinates: [CLLocationCoordinate2D] {
        entry.locations.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
    }

    private var cameraPosition: MapCameraPosition {
        guard !coordinates.isEmpty else { return .automatic }
        if coordinates.count == 1 {
            return .region(MKCoordinateRegion(
                center: coordinates[0],
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))
        }
        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lons.min()! + lons.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (lats.max()! - lats.min()!) * 1.8 + 0.01,
            longitudeDelta: (lons.max()! - lons.min()!) * 1.8 + 0.01
        )
        return .region(MKCoordinateRegion(center: center, span: span))
    }

    var body: some View {
        NavigationView {
            Map(position: .constant(cameraPosition)) {
                ForEach(Array(coordinates.enumerated()), id: \.offset) { index, coord in
                    Annotation("", coordinate: coord) {
                        MapPinView(index: index + 1)
                    }
                }
            }
            .navigationTitle(
                entry.startDateTime.formatted(date: .abbreviated, time: .shortened)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
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
        let items = coordinates.enumerated().map { index, coord -> MKMapItem in
            let item = MKMapItem(placemark: MKPlacemark(coordinate: coord))
            item.name = "Location \(index + 1)"
            return item
        }
        MKMapItem.openMaps(with: items, launchOptions: nil)
    }
}
//
//#Preview {
//    LocationMapCard(
//        event: AvailabilityEvent(
//            id: "cf5f3e6b-a62b-4c43-85f5-e47ca287419f",
//            eventId: "xN6ncT0Foa0UdFy06GSL",
//            geoPoint: GeoPoint(latitude: 43.2, longitude: 9.3),
//            dateLocationId: "milano_centro_001",
//            activityType: "Coffee",
//            startDateTime: Date().addingTimeInterval(3600),
//            endDateTime: Date().addingTimeInterval(7200),
//            createdAt: Date(),
//            g: GeoLocation(geopoint: Coordinate(latitude: 43.2, longitude: 9.3), geohash: "u0ndx37j"),
//            isDateConfirmed: true,
//            isLocationConfirmed: false,
//            isPublic: true,
//            eventImage: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s",
//            creatorName: "Ahmed"
//        )
//    )
//}
