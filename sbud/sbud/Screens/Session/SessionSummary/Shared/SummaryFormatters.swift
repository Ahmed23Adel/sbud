//
//  SummaryFormatters.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation

enum SummaryFormatters {

    static func pace(_ minPerKm: Double) -> String {
        guard minPerKm > 0 && minPerKm.isFinite && minPerKm < 99 else { return "--:--" }
        let total = Int(minPerKm * 60) // converts to seco
        return String(format: "%d'%02d\"", total / 60, total % 60)//%02 secs must be always two digits
    }

    static func duration(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        if h > 0 { return String(format: "%dh %02dm %02ds", h, m, s) }
        return String(format: "%02dm %02ds", m, s)
    }

    static func durationShort(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    static func speed(_ kmH: Double) -> String {
        guard kmH > 0 && kmH.isFinite else { return "--" }
        return String(format: "%.1f", kmH)
    }

    static func distance(_ km: Double) -> String {
        String(format: "%.2f", km)
    }

    static func elevation(_ meters: Double) -> String {
        String(format: "%.0f m", meters)
    }
}
