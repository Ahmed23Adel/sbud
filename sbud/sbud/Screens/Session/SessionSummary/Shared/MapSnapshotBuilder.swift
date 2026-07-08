//
//  MapSnapshotBuilder.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import MapKit
import SwiftUI

/// Generates a static map image with all participant GPS routes drawn as coloured polylines.
/// Used by the share-card renderer — avoids UIViewRepresentable inside ImageRenderer.
enum MapSnapshotBuilder {

    // MARK: - Public API

    /// Returns a rendered UIImage with every participant track drawn, or nil if there is no GPS data.
    ///
    /// - Parameters:
    ///   - summaries: Participant summaries that carry `track: [TrackPoint]`.
    ///   - size: Output size in points. Defaults to the share card width × 150 pt.
    ///   - scale: Pixel scale for the output image (pass 3.0 for @3x share quality).
    static func snapshot(
        summaries: [ParticipantSummary],
        size: CGSize = CGSize(width: 340, height: 150),
        scale: CGFloat = 3.0
    ) async -> UIImage? {
        // Gather every coordinate across all participants
        let allCoords = summaries.flatMap {
            $0.track.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        }
        // A polyline needs at least 2 points — bail out early if there is nothing to draw
        guard allCoords.count > 1 else { return nil }

        // Build a bounding region that contains all routes, with 40% padding
        // so the tracks don't touch the edges, plus a minimum span so that
        // very short routes (< 100 m) still produce a readable map.
        let lats = allCoords.map(\.latitude)
        let lons = allCoords.map(\.longitude)
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lons.min()! + lons.max()!) / 2
        )
        let spanLat = max((lats.max()! - lats.min()!) * 1.4, 0.005)
        let spanLon = max((lons.max()! - lons.min()!) * 1.4, 0.005)

        // Configure the snapshotter — dark style, no POIs, no buildings
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
        )
        options.size = size
        options.scale = scale
        options.mapType = .mutedStandard
        options.pointOfInterestFilter = .excludingAll
        options.showsBuildings = false
        // Force dark appearance so the card always has a dark map regardless of device setting
        options.traitCollection = UITraitCollection(userInterfaceStyle: .dark)

        let snapshotter = MKMapSnapshotter(options: options)

        // Take the base map snapshot via a checked continuation
        // (MKMapSnapshotter's callback is delivered on the main queue by default)
        let baseSnapshot = await withCheckedContinuation { (continuation: CheckedContinuation<MKMapSnapshotter.Snapshot?, Never>) in
            snapshotter.start { snapshot, _ in
                continuation.resume(returning: snapshot)
            }
        }
        guard let baseSnapshot else { return nil }

        // Draw each participant's route as a coloured polyline on top of the snapshot image.
        // UIGraphicsImageRenderer is thread-safe and matches the snapshot's own scale.
        let format = UIGraphicsImageRendererFormat()
        format.scale = baseSnapshot.image.scale

        return UIGraphicsImageRenderer(size: baseSnapshot.image.size, format: format).image { _ in
            // Paint the base map
            baseSnapshot.image.draw(at: .zero)

            for summary in summaries {
                let coords = summary.track.map {
                    CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                }
                // Skip participants with no or insufficient GPS data
                guard coords.count > 1 else { continue }

                // snapshot.point(for:) converts map coordinates → image-space points
                let path = UIBezierPath()
                var isFirst = true
                for coord in coords {
                    let pt = baseSnapshot.point(for: coord)
                    if isFirst { path.move(to: pt); isFirst = false }
                    else { path.addLine(to: pt) }
                }
                path.lineWidth = 3.5
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                UIColor(summary.color).setStroke()
                path.stroke()
            }
        }
    }
}
