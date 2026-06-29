//
//  MultiRouteMapView.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI
import MapKit

struct MultiRouteMapView: UIViewRepresentable {
    let tracks: [(color: UIColor, coordinates: [CLLocationCoordinate2D])]
    let selectedTrackIndex: Int?  // nil = show all

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.mapType = .mutedStandard // low-contrast base map
        map.overrideUserInterfaceStyle = .dark
        map.pointOfInterestFilter = .excludingAll// // hide restaurants, etc.
        map.showsUserLocation = false
        map.isUserInteractionEnabled = true
        map.delegate = context.coordinator
        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)

        let tracksToShow: [(color: UIColor, coordinates: [CLLocationCoordinate2D])]
        if let idx = selectedTrackIndex, idx < tracks.count {
            tracksToShow = [tracks[idx]]
        } else {
            tracksToShow = tracks
        }

        var allRects: [MKMapRect] = [] // allRects accumulates bounding boxes — used later to fit the camera.
        for (index, track) in tracksToShow.enumerated() {
            guard track.coordinates.count > 1 else { continue } // A polyline needs at least 2 points to draw a line. If a track has 0 or 1 point, skip it and move to the next iteration.
            let polyline = ColoredPolyline(coordinates: track.coordinates, count: track.coordinates.count)
            polyline.color = track.color
            polyline.trackIndex = index
            mapView.addOverlay(polyline, level: .aboveRoads)
            // Creates a temporary plain MKPolyline just to access its .boundingMapRect — the smallest rectangle (in map coordinates) that contains all the track's points.
            allRects.append(MKPolyline(coordinates: track.coordinates, count: track.coordinates.count).boundingMapRect)
        }
        // reduce folds an array down to a single value by applying a closure repeatedly.
        // Starting value is nil
        // as MKMapRect? tells Swift the type is Optional<MKMapRect>
        // acc — the accumulated result so far (MKMapRect?)
        // rect — the current element from the array (MKMapRect)
        if let union = allRects.reduce(nil as MKMapRect?, { acc, rect in
            acc.map { $0.union(rect) } ?? rect
        }) {
            mapView.setVisibleMapRect(union,
                                      edgePadding: UIEdgeInsets(top: 60, left: 40, bottom: 60, right: 40),
                                      animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? ColoredPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }
            let r = MKPolylineRenderer(polyline: polyline)
            r.strokeColor = polyline.color ?? .cyan
            r.lineWidth = 3.5
            r.lineCap = .round
            r.lineJoin = .round
            return r
        }
    }
}

// Carries color metadata through MapKit's overlay system
final class ColoredPolyline: MKPolyline {
    var color: UIColor?
    var trackIndex: Int = 0
}

