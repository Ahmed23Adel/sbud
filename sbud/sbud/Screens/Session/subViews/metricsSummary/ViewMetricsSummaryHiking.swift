//
//  ViewMetricsSummaryHiking.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import SwiftUI

struct ViewMetricsSummaryHiking: View {
    var collector: MetricsCollectorHiking

    var body: some View {
        VStack {
            HStack {
                Text("Total Distance:")
                    .font(.title3).foregroundColor(Color.mainColor)
                Text(String(format: "%.0f", collector.totalDistanceMeters))
                    .font(.title3).foregroundColor(Color.mainColor)
                Spacer()
                Text("m").foregroundColor(.gray)
            }
            .padding()

            HStack {
                Text("Current Speed:")
                    .font(.title3).foregroundColor(Color.mainColor)
                Text(String(format: "%.1f", collector.currentSpeedKmH))
                    .font(.title3).foregroundColor(Color.mainColor)
                Spacer()
                Text("km/h").foregroundColor(.gray)
            }
            .padding()

            HStack {
                Text("Avg Speed:")
                    .font(.title3).foregroundColor(Color.mainColor)
                Text(String(format: "%.1f", collector.averageSpeedKmH))
                    .font(.title3).foregroundColor(Color.mainColor)
                Spacer()
                Text("km/h").foregroundColor(.gray)
            }
            .padding()

            HStack {
                Text("Elevation Gain:")
                    .font(.title3).foregroundColor(Color.mainColor)
                Text(String(format: "%.0f", collector.elevationGainMeters))
                    .font(.title3).foregroundColor(Color.mainColor)
                Spacer()
                Text("m").foregroundColor(.gray)
            }
            .padding()

            HStack {
                Text("Elevation Loss:")
                    .font(.title3).foregroundColor(Color.mainColor)
                Text(String(format: "%.0f", collector.elevationLossMeters))
                    .font(.title3).foregroundColor(Color.mainColor)
                Spacer()
                Text("m").foregroundColor(.gray)
            }
            .padding()

            HStack {
                Text("Max Altitude:")
                    .font(.title3).foregroundColor(Color.mainColor)
                Text(String(format: "%.0f", collector.maxAltitudeMeters == -.infinity ? 0 : collector.maxAltitudeMeters))
                    .font(.title3).foregroundColor(Color.mainColor)
                Spacer()
                Text("m").foregroundColor(.gray)
            }
            .padding()

            HStack {
                Text("Current Altitude:")
                    .font(.title3).foregroundColor(Color.mainColor)
                Text(String(format: "%.0f", collector.currentAltitudeMeters))
                    .font(.title3).foregroundColor(Color.mainColor)
                Spacer()
                Text("m").foregroundColor(.gray)
            }
            .padding()
        }
    }
}
