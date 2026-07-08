//
//  EventWeatherWidget.swift
//  sbud
//
//  Created by ahmed on 22/05/2026.
//

import SwiftUI

struct EventWeatherWidget: View {
    let finalStart: Date
    let finalEnd: Date
    let latitude: Double
    let longitude: Double

    @State private var vm = WeatherViewModel()

    private let hourFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Weather Forecast", systemImage: "cloud.sun.fill")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            if vm.isLoading {
                HStack { Spacer(); ProgressView().tint(.white); Spacer() }
                    .padding()
            } else if let err = vm.error {
                Text("Could not load weather: \(err)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else if vm.slices.isEmpty {
                Text("No forecast available for this date.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(vm.slices) { slice in
                            HourlyCard(slice: slice, hourFmt: hourFmt)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .task {
            await vm.load(lat: latitude, lon: longitude, start: finalStart, end: finalEnd)
        }
    }
}

//#Preview {
//    EventWeatherWidget()
//}
