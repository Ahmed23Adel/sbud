//
//  ProfilePerformanceCard.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct ProfilePerformanceCard: View {
    let profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().background(Color(white: 0.12)).padding(.vertical, 16)
            topMetricsRow
            Divider().background(Color(white: 0.12)).padding(.vertical, 16)
            bottomMetricsRow
            if let activityStats = profile.activityStats, !activityStats.isEmpty {
                Divider().background(Color(white: 0.12)).padding(.vertical, 16)
                activityBreakdown(activityStats)
            }
            Divider().background(Color(white: 0.12)).padding(.vertical, 12)
            lastActivityRow
        }
        .padding(20)
        .background(Color(white: 0.07))
        .clipShape(Rectangle())
        .padding(.horizontal, 16)
        .cornerRadius(4)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("PERFORMANCE METRICS")
                .font(.system(size: 15, weight: .black))
                .foregroundColor(.white)
                .kerning(1.5)
            Spacer()
            if let streak = profile.currentStreakDays, streak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 12))
                    Text("\(streak)d streak")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(6)
            }
        }
    }

    // MARK: - Top row: sessions, distance, duration

    private var topMetricsRow: some View {
        HStack(alignment: .top) {
            ProfileMetricItem(
                label: "SESSIONS",
                value: "\(profile.totalSessions)",
                color: Color("turquoise")
            )
            Spacer()
            ProfileMetricItem(
                label: "DISTANCE (KM)",
                value: ProfileUtils.formatDistance(profile.totalDistanceKm),
                color: .white
            )
            Spacer()
            if let hours = profile.totalDurationHours {
                ProfileMetricItem(
                    label: "HOURS",
                    value: String(format: "%.1f", hours),
                    color: .white
                )
            }
        }
    }

    // MARK: - Bottom row: intensity, monthly sessions, favorite activity

    private var bottomMetricsRow: some View {
        HStack(alignment: .top) {
            ProfileMetricItem(
                label: "AVG. INTENSITY",
                value: "\(profile.avgIntensity) %",
                color: .white
            )
            Spacer()
            if let monthly = profile.monthlySessionCount {
                ProfileMetricItem(
                    label: "THIS MONTH",
                    value: "\(monthly)",
                    color: Color("palelime")
                )
            }
            Spacer()
            if let fav = profile.favoriteActivity {
                VStack(alignment: .leading, spacing: 5) {
                    Text("FAVOURITE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                        .kerning(1)
                    HStack(spacing: 6) {
                        Image(systemName: activityIcon(fav))
                            .foregroundColor(Color("palelime"))
                            .font(.system(size: 18, weight: .bold))
                        Text(fav.uppercased())
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(Color("palelime"))
                    }
                }
            }
        }
    }

    // MARK: - Activity breakdown

    private func activityBreakdown(_ stats: [String: ActivityStat]) -> some View {
        let sorted = stats.sorted { $0.value.sessionCount > $1.value.sessionCount }
        return VStack(alignment: .leading, spacing: 10) {
            Text("BY ACTIVITY")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .kerning(1)
            ForEach(sorted, id: \.key) { activity, stat in
                HStack {
                    Image(systemName: activityIcon(activity))
                        .foregroundColor(Color("turquoise"))
                        .font(.system(size: 13))
                        .frame(width: 20)
                    Text(activity.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(stat.sessionCount) sessions")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.gray)
                    Text("·")
                        .foregroundColor(.gray)
                    Text(String(format: "%.1f km", stat.totalDistanceKm))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    if let pb = stat.personalBestDistanceKm, pb > 0 {
                        Text("· PB \(String(format: "%.1f", pb))km")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(Color("palelime"))
                    }
                }
            }
        }
    }

    // MARK: - Last activity row

    private var lastActivityRow: some View {
        HStack {
            Text(ProfileUtils.lastActivityText(
                date: profile.lastActivityDate,
                name: profile.lastActivityName
            ))
            .font(.system(size: 10, design: .monospaced))
            .foregroundColor(.gray)
            Spacer()
            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundColor(Color("palelime"))
                .font(.system(size: 14))
        }
    }

    // MARK: - Helpers

    private func activityIcon(_ activity: String) -> String {
        switch activity.lowercased() {
        case "running":  return "figure.run"
        case "cycling":  return "figure.outdoor.cycle"
        case "hiking":   return "figure.hiking"
        case "swimming": return "figure.pool.swim"
        case "skiing":   return "figure.skiing.downhill"
        case "gym":      return "dumbbell"
        case "yoga":     return "figure.yoga"
        case "tennis":   return "figure.tennis"
        default:         return "figure.mixed.cardio"
        }
    }
}
