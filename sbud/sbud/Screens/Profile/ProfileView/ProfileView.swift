//
//  ProfileView.swift
//  sbud
//
//  Created by Erdal on 27.04.2026.
//

import SwiftUI
import Kingfisher

struct ProfileView: View {
    @StateObject private var vm: ProfileVM
    @EnvironmentObject var coordinator: MainCoordinator

    init(userId: String) {
        _vm = StateObject(wrappedValue: ProfileVM(userId: userId))
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                if vm.isLoading {
                    Spacer()
                    ProgressView().tint(Color("palelime"))
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            avatarSection
                            if vm.isOwnProfile {    editButton  }
                            else {  followButtons   }
                            statsRow
                            performanceCard
                            archiveSection
                        }
                        .padding(.bottom, 80)
                    }
                }
            }
        }
        .task { await vm.load() }
    }
}

// MARK: - Subviews
private extension ProfileView {
    
    // MARK: Navbar
    var navBar: some View {
        HStack {
            if !vm.isOwnProfile {
                Button { coordinator.goBack() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
            
            Spacer()
            
            if vm.isOwnProfile {
                Button { coordinator.goToSettings() } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)}
            }   else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05))
    }
    
    // MARK: Avatar
    var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color("turquoise").opacity(0.6), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 118, height: 118)
                
                Group {
                    if let urlStr = vm.profile?.profileImageUrl,
                       let url = URL(string: urlStr) {
                        KFImage(url)
                            .placeholder {
                                Circle().fill(Color(white: 0.15))
                                    .overlay(ProgressView().tint(.white))
                            }
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(28)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 108, height: 108)
                .clipShape(Circle())
            }
            .padding(.top, 20)
            
            Text(vm.displayName.isEmpty ? "—" : vm.displayName)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.white)
        }
    }
    
    var editButton: some View {
        Button(action: {}) {
            Text("EDIT PROFILE")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color("palelime"))
                .clipShape(Rectangle())
                .cornerRadius(4)
        }
        .padding(.horizontal, 24)
    }
    
    var followButtons: some View {
        Button {
            Task { await vm.toggleFollow() }
        } label: {
            ZStack {
                if vm.isFollowLoading {
                    ProgressView().tint(.black)
                } else {
                    Text(vm.isFollowing ? "UNFOLLOW" : "FOLLOW")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.isFollowing ? .white : .black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(vm.isFollowing ? Color(white: 0.2) : Color("palelime"))
            .clipShape(Rectangle())
            .cornerRadius(4)
        }
        .padding(.horizontal, 24)
    }
    
    
    // MARK: Stats Row
    var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: formatCount(vm.profile?.followersCount ?? 0), label: "FOLLOWERS")
            Rectangle().fill(Color(white: 0.15)).frame(width: 1, height: 28)
            statItem(value: formatCount(vm.profile?.followingCount ?? 0), label: "FOLLOWING")
            Rectangle().fill(Color(white: 0.15)).frame(width: 1, height: 28)
        }
        .padding(.vertical, 16)
        .background(Color(white: 0.07))
    }
    
    func statItem(value: String, label: String) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .kerning(1)
        }
        .frame(maxWidth: .infinity)
    }
    
    var performanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PERFORMANCE METRICS")
                .font(.system(size: 15, weight: .black))
                .foregroundColor(.white)
                .kerning(1.5)
            
            HStack(alignment: .top) {
                metricItem(label: "TOTAL SESSIONS",
                           value: "\(vm.profile?.totalSessions ?? 0)",
                           color: Color("turquoise"))
                Spacer()
                metricItem(label: "DISTANCE (KM)",
                           value: formatDistance(vm.profile?.totalDistanceKm ?? 0),
                           color: .white)
            }
            
            metricItem(label: "AVG. INTENSITY",
                       value: "\(vm.profile?.avgIntensity ?? 0) %",
                       color: .white)
            
            Divider().background(Color(white: 0.12))
            
            HStack {
                Text(lastActivityText)
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
    
    func metricItem(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .kerning(1)
            Text(value)
                .font(.system(size: 36, weight: .black, design: .monospaced))
                .foregroundColor(color)
        }
    }
    
    var archiveSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("ARCHIVE HISTORY")
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                Spacer()
                Text("VIEW ALL")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color("turquoise"))
            }
            
            // TODO: REAL VVALUE WİLL BE ADD HERE LATER.
            Text("No activity history yet.")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
        }
        .padding(20)
        .background(Color(white: 0.07))
        .clipShape(Rectangle())
        .padding(.horizontal, 16)
        .cornerRadius(4)
    }

    private var lastActivityText: String {
        guard let date = vm.profile?.lastActivityDate,
              let name = vm.profile?.lastActivityName else {
            return "No recent activity"
        }
        return "Last activity: \(timeAgo(date)) • \(name)"
    }

    private func formatCount(_ n: Int) -> String {
        n >= 1000 ? String(format: "%.1fK", Double(n) / 1000) : "\(n)"
    }

    private func formatDistance(_ km: Double) -> String {
        km >= 1000 ? String(format: "%.1fK", km / 1000) : String(format: "%.0f", km)
    }

    private func timeAgo(_ date: Date) -> String {
        let diff = Int(Date().timeIntervalSince(date))
        if diff < 3600  { return "\(diff / 60)m ago" }
        if diff < 86400 { return "\(diff / 3600)h ago" }
        return "\(diff / 86400)d ago"
    }
}

#Preview {
    ProfileView(userId: "preview")
}
