//
//  Weather.swift
//  sbud
//
//  Created by ahmed on 22/05/2026.
//


import SwiftUI

// MARK: - Models

struct OpenMeteoResponse: Decodable {
    let hourly: HourlyData
}

struct HourlyData: Decodable {
    let time: [String]
    let temperature_2m: [Double?]
    let precipitation_probability: [Int?]
    let weathercode: [Int?]
    let windspeed_10m: [Double?]
}

struct HourlySlice: Identifiable {
    let id = UUID()
    let time: Date
    let temp: Double
    let precipProb: Int
    let code: Int
    let wind: Double
}

// MARK: - WMO Code helpers

func wmoDescription(_ code: Int) -> String {
    switch code {
    case 0:        return "Clear sky"
    case 1...3:    return "Partly cloudy"
    case 45, 48:   return "Foggy"
    case 51...57:  return "Drizzle"
    case 61...67:  return "Rain"
    case 71...77:  return "Snow"
    case 80...82:  return "Rain showers"
    case 85, 86:   return "Snow showers"
    case 95:       return "Thunderstorm"
    case 96, 99:   return "Thunderstorm + hail"
    default:       return "Mixed conditions"
    }
}

func wmoSFSymbol(_ code: Int) -> String {
    switch code {
    case 0:        return "sun.max.fill"
    case 1...3:    return "cloud.sun.fill"
    case 45, 48:   return "cloud.fog.fill"
    case 51...57:  return "cloud.drizzle.fill"
    case 61...67:  return "cloud.rain.fill"
    case 71...77:  return "cloud.snow.fill"
    case 80...82:  return "cloud.heavyrain.fill"
    case 85, 86:   return "cloud.snow.fill"
    case 95:       return "cloud.bolt.rain.fill"
    case 96, 99:   return "cloud.bolt.rain.fill"
    default:       return "cloud.fill"
    }
}

/// WMO Weather Code — it stands for World Meteorological Organization. It's an international standard numbering system for weather conditions, not something Open-Meteo invented. Every number maps to a specific condition:
/// 0        → Clear sky
//1, 2, 3  → Mainly clear, partly cloudy, overcast
//45, 48   → Fog
//51-57    → Drizzle (light to freezing)
//61-67    → Rain (light to freezing)
//71-77    → Snow
//80-82    → Rain showers
//85-86    → Snow showers
//95       → Thunderstorm
//96, 99   → Thunderstorm with hail
func wmoColor(_ code: Int) -> Color {
    switch code {
    case 0:        return .yellow
    case 1...3:    return .orange
    case 45, 48:   return .gray
    case 51...82:  return .blue
    case 71...77:  return .cyan
    case 85...99:  return .indigo
    default:       return .gray
    }
}
