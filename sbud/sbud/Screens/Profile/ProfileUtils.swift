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

    static func formatDistance(_ km: Double) -> String {
        km >= 1000 ? String(format: "%.1fK", km / 1000) : String(format: "%.0f", km)
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

    // MARK: - Privacy

    static func canShowEmail(profile: UserProfile, isFriend: Bool, isOwnProfile: Bool) -> Bool {
        isOwnProfile || ((profile.showEmail ?? false) && isFriend)
    }

    static func canShowPhone(profile: UserProfile, isFriend: Bool, isOwnProfile: Bool) -> Bool {
        isOwnProfile || ((profile.showPhone ?? false) && isFriend)
    }
}
