//
//  ProfilePerformanceCard.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct ProfilePerformanceCard: View {
    let profile: UserProfile
    var statsLoaded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            fixedHeader
                .padding(.horizontal, 20)
                .padding(.top, 20)

            Divider().background(Color(white: 0.12))
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

            overallContent

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
            PageSectionTitle(title: "PERFORMANCE METRICS")
            Spacer()

        }
    }

    // MARK: - Overall Content (2x2 sabit sütun grid)

    private var overallContent: some View {
        // Her sütun eşit genişlikte → hizalar her satırda aynı
        HStack(alignment: .top, spacing: 0) {
            // Sol sütun: SESSIONS üstte, TIME altta
            VStack(alignment: .leading, spacing: 20) {
                ProfileMetricItem(label: "SESSIONS",
                                  value: "\(profile.totalSessions)",
                                  color: Color("turquoise"))
                ProfileMetricItem(label: "TIME",
                                  value: ProfileUtils.durationNumber(profile.totalDurationHours ?? 0),
                                  color: .white,
                                  unit: ProfileUtils.durationUnit(profile.totalDurationHours ?? 0))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Sağ sütun: DISTANCE üstte, THIS MONTH altta
            VStack(alignment: .leading, spacing: 20) {
                ProfileMetricItem(label: "DISTANCE",
                                  value: ProfileUtils.distanceNumber(profile.totalDistanceKm),
                                  color: .white,
                                  unit: ProfileUtils.distanceUnit(profile.totalDistanceKm))
                ProfileMetricItem(label: "THIS MONTH",
                                  value: "\(profile.monthlySessionCount ?? 0)",
                                  color: Color("palelime"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }

    // MARK: - Last Activity

    private func lastActivityRow(now: Date) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
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
