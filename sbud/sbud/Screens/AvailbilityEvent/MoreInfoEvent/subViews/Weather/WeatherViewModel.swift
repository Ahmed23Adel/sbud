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

    private let fetcher: WeatherFetching

    init(fetcher: WeatherFetching = URLSessionWeatherFetcher()) {
        self.fetcher = fetcher
    }

    // MARK: - Testable static helpers

    /// Caps the weather window to 24 hours so we never request more than a day of data.
    static func clampEnd(_ end: Date, from start: Date) -> Date {
        min(end, start.addingTimeInterval(86400))
    }

    static func buildURLString(lat: Double, lon: Double, startStr: String, endStr: String) -> String {
        "https://api.open-meteo.com/v1/forecast" +
        "?latitude=\(lat)&longitude=\(lon)" +
        "&hourly=temperature_2m,precipitation_probability,weathercode,windspeed_10m" +
        "&start_date=\(startStr)&end_date=\(endStr)" +
        "&timezone=auto&timeformat=unixtime"
    }

    // MARK: - Load

    func load(lat: Double, lon: Double, start: Date, end: Date) async {
        await MainActor.run { isLoading = true; error = nil }

        let clampedEnd = WeatherViewModel.clampEnd(end, from: start)

        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withFullDate]
        let startStr = fmt.string(from: start)
        let endStr   = fmt.string(from: clampedEnd)

        let urlStr = WeatherViewModel.buildURLString(lat: lat, lon: lon, startStr: startStr, endStr: endStr)

        guard let url = URL(string: urlStr) else {
            await MainActor.run { error = "Invalid URL"; isLoading = false }
            return
        }

        do {
            let data = try await fetcher.fetchData(from: url)
            let slices = try WeatherViewModel.parseData(data)
            await MainActor.run {
                self.slices = slices
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - Parsing (internal so tests can call it directly)

    static func parseData(_ data: Data) throws -> [HourlySlice] {
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

        return h.time.indices.compactMap { idx in
            let date = Date(timeIntervalSince1970: h.time[idx])
            return HourlySlice(
                time:       date,
                temp:       h.temperature_2m?[idx] ?? 0,
                precipProb: Int(h.precipitation_probability?[idx] ?? 0),
                code:       Int(h.weathercode?[idx] ?? 0),
                wind:       h.windspeed_10m?[idx] ?? 0
            )
        }
    }
}
