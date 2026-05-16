//
//  ViewMetricsSummaryCycling.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import SwiftUI


struct ViewMetricsSummaryCycling: View {
    var collector: MetricsCollectorCycling

    var body: some View {
        VStack {
            HStack {
                Text("Total Distance:")
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                Text(String(format: "%.0f", collector.totalDistanceMeters))
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                Spacer()
                Text("m")
                    .foregroundColor(.gray)
            }
            .padding()

            HStack {
                Text("Current Speed:")
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                Text(String(format: "%.1f", collector.currentSpeedKmH))
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                Spacer()
                Text("km/h")
                    .foregroundColor(.gray)
            }
            .padding()

            HStack {
                Text("Average Speed:")
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                Text(String(format: "%.1f", collector.averageSpeedKmH))
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                Spacer()
                Text("km/h")
                    .foregroundColor(.gray)
            }
            .padding()

            HStack {
                Text("Max Speed:")
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                Text(String(format: "%.1f", collector.maxSpeedKmH == -.infinity ? 0 : collector.maxSpeedKmH))
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                Spacer()
                Text("km/h")
                    .foregroundColor(.gray)
            }
            .padding()

            HStack {
                Text("Elevation Gain:")
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                Text(String(format: "%.0f", collector.elevationGainMeters))
                    .font(.title3)
                    .foregroundColor(Color.mainColor)
                Spacer()
                Text("m")
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

//#Preview {
//    ViewMetricsSummaryCycling()
//}
