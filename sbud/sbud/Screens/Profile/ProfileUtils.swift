//
//  ProfileUtils.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation

enum ProfileUtils {

    // MARK: - Formatting

    static func formatCount(_ n: Int) -> String {
        n >= 1000 ? String(format: "%.1fK", Double(n) / 1000) : "\(n)"
    }

    /// < 1 km → "XXX m"  |  >= 1 km → "X.X km"
    static func formatDistance(_ km: Double) -> String {
        if km == 0 { return "0" }
        if km < 1 { return String(format: "%.0f m", km * 1000) }
        return String(format: "%.1f km", km)
    }

    /// < 60 min → "XX min"  |  >= 1 h → "Xh XXm"
    static func formatDuration(_ hours: Double) -> String {
        if hours == 0 { return "0 min" }
        let totalMinutes = Int(hours * 60)
        if totalMinutes < 60 { return "\(totalMinutes) min" }
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }

    static func timeAgo(_ date: Date) -> String {
        let diff = Int(Date().timeIntervalSince(date))
        if diff < 3600  { return "\(diff / 60)m ago" }
        if diff < 86400 { return "\(diff / 3600)h ago" }
        return "\(diff / 86400)d ago"
    }

    static func lastActivityText(date: Date?, name: String?) -> String {
        guard let date, let name else { return "No recent activity" }
        return "Last activity: \(timeAgo(date)) • \(name)"
    }

    // Number + unit split helpers for ProfileMetricItem

    static func distanceNumber(_ km: Double) -> String {
        if km == 0 { return "0" }
        if km < 1 { return String(format: "%.0f", km * 1000) }
        return String(format: "%.1f", km)
    }

    static func distanceUnit(_ km: Double) -> String {
        km > 0 && km < 1 ? "m" : "km"
    }

    static func durationNumber(_ hours: Double) -> String {
        if hours == 0 { return "0" }
        let totalMinutes = Int(hours * 60)
        if totalMinutes < 60 { return "\(totalMinutes)" }
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        return m > 0 ? "\(h)h \(m)" : "\(h)"
    }

    static func durationUnit(_ hours: Double) -> String {
        if hours == 0 { return "min" }
        let totalMinutes = Int(hours * 60)
        if totalMinutes < 60 { return "min" }
        let m = totalMinutes % 60
        return m > 0 ? "m" : "h"
    }

    // MARK: - Privacy

    static func canShowEmail(profile: UserProfile, isFriend: Bool, isOwnProfile: Bool) -> Bool {
        isOwnProfile || ((profile.showEmail ?? false) && isFriend)
    }

    static func canShowPhone(profile: UserProfile, isFriend: Bool, isOwnProfile: Bool) -> Bool {
        isOwnProfile || ((profile.showPhone ?? false) && isFriend)
    }
}

