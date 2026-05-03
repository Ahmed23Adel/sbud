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
        VStack(alignment: .leading, spacing: 16) {
            Text("PERFORMANCE METRICS")
                .font(.system(size: 15, weight: .black))
                .foregroundColor(.white)
                .kerning(1.5)
 
            HStack(alignment: .top) {
                ProfileMetricItem(
                    label: "TOTAL SESSIONS",
                    value: "\(profile.totalSessions ?? 0)",
                    color: Color("turquoise")
                )
                Spacer()
                ProfileMetricItem(
                    label: "DISTANCE (KM)",
                    value: ProfileUtils.formatDistance(profile.totalDistanceKm ?? 0),
                    color: .white
                )
            }
 
            ProfileMetricItem(
                label: "AVG. INTENSITY",
                value: "\(profile.avgIntensity ?? 0) %",
                color: .white
            )
 
            Divider().background(Color(white: 0.12))
 
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
        .padding(20)
        .background(Color(white: 0.07))
        .clipShape(Rectangle())
        .padding(.horizontal, 16)
        .cornerRadius(4)
    }
}
//
//#Preview {
//    ProfilePerformanceCard()
//}
