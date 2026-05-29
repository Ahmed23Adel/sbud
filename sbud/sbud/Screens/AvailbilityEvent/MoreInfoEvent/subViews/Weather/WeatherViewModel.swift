//
//  WeatherViewModel.swift
//  sbud
//
//  Created by ahmed on 22/05/2026.
//

import Foundation

@Observable

class WeatherViewModel {
    var slices: [HourlySlice] = []
    var isLoading = false
    var error: String? = nil

    func load(lat: Double, lon: Double, start: Date, end: Date) async {
        await MainActor.run { isLoading = true; error = nil }

        // It caps the weather window to a maximum of 24 hours. 86400 is the number of seconds in a day (60 × 60 × 24).
        let clampedEnd = min(end, start.addingTimeInterval(86400))

        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withFullDate]
        let startStr = fmt.string(from: start)
        let endStr   = fmt.string(from: clampedEnd)

        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&hourly=temperature_2m,precipitation_probability,weathercode,windspeed_10m&start_date=\(startStr)&end_date=\(endStr)&timezone=auto&timeformat=unixtime"

        guard let url = URL(string: urlStr) else {
            await MainActor.run { error = "Invalid URL"; isLoading = false }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            struct RawHourly: Decodable {
                let time: [TimeInterval]
                let temperature_2m: [Double?]?
                let precipitation_probability: [Double?]?
                let weathercode: [Double?]?
                let windspeed_10m: [Double?]?
            }
            struct RawResponse: Decodable { let hourly: RawHourly }
            
            let decoded = try JSONDecoder().decode(RawResponse.self, from: data)
            let h = decoded.hourly

            let result: [HourlySlice] = h.time.indices.compactMap { idx in
                let date = Date(timeIntervalSince1970: h.time[idx])
                return HourlySlice(
                    time:       date,
                    temp:       h.temperature_2m?[idx] ?? 0,
                    precipProb: Int(h.precipitation_probability?[idx] ?? 0),
                    code:       Int(h.weathercode?[idx] ?? 0),
                    wind:       h.windspeed_10m?[idx] ?? 0
                )
            }

            await MainActor.run {
                slices = result
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
}
