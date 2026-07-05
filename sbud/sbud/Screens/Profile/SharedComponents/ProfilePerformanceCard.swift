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

            fixedHeader
                .padding(.horizontal, 20)
                .padding(.top, 20)

            Divider().background(Color(white: 0.12))
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

            overallContent
                .padding(.bottom, 4)

            Divider().background(Color(white: 0.12))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

            TimelineView(.periodic(from: .now, by: 60)) { _ in
                lastActivityRow(now: Date())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(white: 0.07))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.horizontal, 16)
    }

    // MARK: - Header

    private var fixedHeader: some View {
        HStack {
            Text("PERFORMANCE METRICS")
                .font(.system(size: 13, weight: .black))
                .foregroundColor(.white)
                .kerning(1.2)
            Spacer()
            if let streak = profile.currentStreakDays, streak > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 11))
                    Text("\(streak)d Streak")
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

    // MARK: - Overall Content

    private var overallContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                ProfileMetricItem(label: "SESSIONS",
                                  value: "\(profile.totalSessions)",
                                  color: Color("turquoise"))
                Spacer()
                ProfileMetricItem(label: "DISTANCE (KM)",
                                  value: ProfileUtils.formatDistance(profile.totalDistanceKm),
                                  color: .white)
                Spacer()
                ProfileMetricItem(label: "HOURS",
                                  value: String(format: "%.1f", profile.totalDurationHours ?? 0),
                                  color: .white)
            }
            .padding(.horizontal, 20)

            HStack(alignment: .top) {
                ProfileMetricItem(label: "AVG. INTENSITY",
                                  value: "\(profile.avgIntensity) %",
                                  color: .white)
                Spacer()
                ProfileMetricItem(label: "THIS MONTH",
                                  value: "\(profile.monthlySessionCount ?? 0)",
                                  color: Color("palelime"))
                Spacer()
                Color.clear.frame(width: 80)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Last Activity

    private func lastActivityRow(now: Date) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("LAST ACTIVITY")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .kerning(1)
                Text(lastActivityText(now: now))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(profile.lastActivityDate == nil ? .gray : .white)
            }
            Spacer()
            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundColor(Color("palelime"))
                .font(.system(size: 13))
        }
    }

    private func lastActivityText(now: Date) -> String {
        guard let name = profile.lastActivityName,
              let date = profile.lastActivityDate else { return "No recent activity" }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return "\(name) · \(f.localizedString(for: date, relativeTo: now))"
    }
}

