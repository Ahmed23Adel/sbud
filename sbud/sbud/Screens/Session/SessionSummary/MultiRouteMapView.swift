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
        map.mapType = .mutedStandard
        map.overrideUserInterfaceStyle = .dark
        map.pointOfInterestFilter = .excludingAll
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

        var allRects: [MKMapRect] = []
        for (index, track) in tracksToShow.enumerated() {
            guard track.coordinates.count > 1 else { continue }
            let polyline = ColoredPolyline(coordinates: track.coordinates, count: track.coordinates.count)
            polyline.color = track.color
            polyline.trackIndex = index
            mapView.addOverlay(polyline, level: .aboveRoads)
            allRects.append(MKPolyline(coordinates: track.coordinates, count: track.coordinates.count).boundingMapRect)
        }

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

