//
//  ProfileView.swift
//  sbud
//
//  Created by Erdal on 25.04.2026.
//
/*
import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            // Arka Plan
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                navBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        
                        // Header: Profil Resmi ve İsim
                        profileHeader
                        
                        // Follow & Message Butonları
                        actionButtons
                        
                        // İstatistikler (Followers, Following, Trust Score)
                        quickStats
                        
                        // Performance Metrics Bölümü
                        performanceMetrics
                        
                        // Archive History Bölümü
                        archiveHistory
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

// MARK: - Subviews
private extension ProfileView {
    
    var navBar: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
            Spacer()
            Text("VOLT_PROFILE")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
            Spacer()
            Image(systemName: "bubble.right")
        }
        .foregroundColor(.white)
        .padding()
    }
    
    var profileHeader: some View {
        VStack(spacing: 15) {
            // Profil Resmi (Dışında parlayan halka ile)
            ZStack {
                Circle()
                    .stroke(LinearGradient(colors: [.cyan, .clear], startPoint: .top, endPoint: .bottom), lineWidth: 2)
                    .frame(width: 130, height: 130)
                    .blur(radius: 2)
                
                Image("jaxon_avatar") // Buraya kendi görselini ekle
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            }
            
            VStack(spacing: 5) {
                Text("JAXON_VOLT_08")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                
                Text("ELITE_TIER_VANGUARD")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .kerning(1.5)
            }
        }
    }
    
    var actionButtons: some View {
        HStack(spacing: 15) {
            Button(action: {}) {
                Text("FOLLOW")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.9, green: 1.0, blue: 0.7))
            }
            
            Button(action: {}) {
                Text("MESSAGE")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.cyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.05))
            }
        }
        .padding(.horizontal)
    }
    
    var quickStats: some View {
        HStack(spacing: 0) { // Spacing'i 0 yapıyoruz ki frame'ler tam birleşsin
            statColumn(value: "12.8K", label: "FOLLOWERS")
            
            dividerLine // Özel divider
            
            statColumn(value: "842", label: "FOLLOWING")
            
            dividerLine // Özel divider
            
            statColumn(value: "98", label: "TRUST SCORE", isBlue: true)
        }
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.03))
    }

    // Kolonları eşit bölen fonksiyon
    func statColumn(value: String, label: String, isBlue: Bool = false) -> some View {
        VStack(spacing: 5) {
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isBlue ? .cyan : .white)
                if isBlue {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.cyan)
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity) // KRİTİK: Eşit dağılımı sağlayan yer burası
    }

    // Aradaki dikey çizgiler için yardımcı view
    var dividerLine: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 1, height: 30)
    }
    
    var performanceMetrics: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("PERFORMANCE_METRICS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            VStack(spacing: 20) {
                HStack {
                    metricItem(label: "TOTAL SESSIONS", value: "248", color: .cyan)
                    Spacer()
                    metricItem(label: "DISTANCE (KM)", value: "1,402", color: .white)
                }
                
                metricItem(label: "AVG. INTENSITY", value: "88%", color: .white)
                
                Divider().background(Color.white.opacity(0.1))
                
                HStack {
                    Text("Last activity: 4 hours ago • Morning Run")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(Color(red: 0.9, green: 1.0, blue: 0.7))
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.05))
            .cornerRadius(4)
            .padding(.horizontal)
        }
    }
    
    func metricItem(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
        }
    }
    
    var archiveHistory: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("ARCHIVE_HISTORY")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                Spacer()
                Text("VIEW_ALL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.cyan)
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                archiveRow(title: "NEON_SPRINT_04", sub: "HIGH INTENSITY • 12.4KM", time: "2H AGO", icon: "bolt.fill", accent: Color(red: 0.9, green: 1.0, blue: 0.7))
                archiveRow(title: "APEX_CLIMB_V3", sub: "ELEVATION • 850M GAIN", time: "YESTERDAY", icon: "mountain.2.fill", accent: .cyan)
                archiveRow(title: "SQUAD_DRILL_ALPHA", sub: "GROUP MISSION • 45MIN", time: "3D AGO", icon: "person.3.fill", accent: .gray)
            }
            .padding(.horizontal)
        }
    }
    
    func archiveRow(title: String, sub: String, time: String, icon: String, accent: Color) -> some View {
        HStack(spacing: 15) {
            // Sol çizgi detayı
            Rectangle()
                .fill(accent)
                .frame(width: 3)
            
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .background(Color.white.opacity(0.05))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(sub)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("COMPLETED")
                    .font(.system(size: 8, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                Text(time)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 65)
        .background(Color.white.opacity(0.03))
    }
}

#Preview {
    ProfileView()
}
*/
/*
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

            if vm.isLoading {
                ProgressView().tint(Color("palelime"))
            } else {
                VStack(spacing: 0) {
                    navBar
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 25) {
                            profileHeader
                            actionButtons
                            quickStats
                            performanceMetrics
                            archiveHistory
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .task { await vm.load() }
    }
}

// MARK: - Subviews
private extension ProfileView {

    var navBar: some View {
        HStack {
            Button { coordinator.goBack() } label: {
                Image(systemName: "line.3.horizontal")
            }
            Spacer()
            Text("VOLT_PROFILE")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
            Spacer()
            Image(systemName: vm.isOwnProfile ? "gearshape" : "bubble.right")
        }
        .foregroundColor(.white)
        .padding()
    }

    var profileHeader: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(colors: [.cyan, .clear], startPoint: .top, endPoint: .bottom),
                        lineWidth: 2
                    )
                    .frame(width: 130, height: 130)
                    .blur(radius: 2)

                Group {
                    if let urlStr = vm.profile?.profileImageUrl,
                       let url = URL(string: urlStr) {
                        KFImage(url)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(30)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            }

            VStack(spacing: 5) {
                Text(vm.displayName.isEmpty ? "—" : vm.displayName)
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)

                Text((vm.profile?.tier ?? "RECRUIT").uppercased())
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .kerning(1.5)
            }
        }
    }

    var actionButtons: some View {
        HStack(spacing: 15) {
            if vm.isOwnProfile {
                Button(action: {}) {
                    Text("EDIT PROFILE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("palelime"))
                }
            } else {
                Button { Task { await vm.toggleFollow() } } label: {
                    Text(vm.isFollowing ? "FOLLOWING" : "FOLLOW")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(vm.isFollowing ? Color(white: 0.3) : Color("palelime"))
                }

                Button(action: {}) {
                    Text("MESSAGE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.05))
                }
            }
        }
        .padding(.horizontal)
    }

    var quickStats: some View {
        HStack(spacing: 0) {
            statColumn(value: formatCount(vm.profile?.followersCount ?? 0), label: "FOLLOWERS")
            dividerLine
            statColumn(value: formatCount(vm.profile?.followingCount ?? 0), label: "FOLLOWING")
            dividerLine
            statColumn(value: "\(vm.profile?.trustScore ?? 0)", label: "TRUST SCORE", isBlue: true)
        }
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.03))
    }

    func statColumn(value: String, label: String, isBlue: Bool = false) -> some View {
        VStack(spacing: 5) {
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isBlue ? .cyan : .white)
                if isBlue {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.cyan)
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    var dividerLine: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 1, height: 30)
    }

    var performanceMetrics: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("PERFORMANCE_METRICS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
                .padding(.horizontal)

            VStack(spacing: 20) {
                HStack {
                    metricItem(label: "TOTAL SESSIONS", value: "\(vm.profile?.totalSessions ?? 0)", color: .cyan)
                    Spacer()
                    metricItem(label: "DISTANCE (KM)", value: formatDistance(vm.profile?.totalDistanceKm ?? 0), color: .white)
                }

                metricItem(label: "AVG. INTENSITY", value: "\(vm.profile?.avgIntensity ?? 0)%", color: .white)

                Divider().background(Color.white.opacity(0.1))

                HStack {
                    Text(lastActivityText)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(Color("palelime"))
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.05))
            .cornerRadius(4)
            .padding(.horizontal)
        }
    }

    func metricItem(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
        }
    }

    var archiveHistory: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("ARCHIVE_HISTORY")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                Spacer()
                Text("VIEW_ALL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.cyan)
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                archiveRow(title: "NEON_SPRINT_04", sub: "HIGH INTENSITY • 12.4KM", time: "2H AGO", icon: "bolt.fill", accent: Color("palelime"))
                archiveRow(title: "APEX_CLIMB_V3", sub: "ELEVATION • 850M GAIN", time: "YESTERDAY", icon: "mountain.2.fill", accent: .cyan)
                archiveRow(title: "SQUAD_DRILL_ALPHA", sub: "GROUP MISSION • 45MIN", time: "3D AGO", icon: "person.3.fill", accent: .gray)
            }
            .padding(.horizontal)
        }
    }

    func archiveRow(title: String, sub: String, time: String, icon: String, accent: Color) -> some View {
        HStack(spacing: 15) {
            Rectangle()
                .fill(accent)
                .frame(width: 3)

            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .background(Color.white.opacity(0.05))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(sub)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("COMPLETED")
                    .font(.system(size: 8, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                Text(time)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 65)
        .background(Color.white.opacity(0.03))
    }

    // MARK: - Helpers
    private var lastActivityText: String {
        guard let date = vm.profile?.lastActivityDate,
              let name = vm.profile?.lastActivityName else {
            return "No recent activity"
        }
        return "Last activity: \(timeAgo(date)) • \(name)"
    }

    private func formatCount(_ count: Int) -> String {
        count >= 1000 ? String(format: "%.1fK", Double(count) / 1000) : "\(count)"
    }

    private func formatDistance(_ km: Double) -> String {
        km >= 1000 ? String(format: "%.1fK", km / 1000) : String(format: "%.0f", km)
    }

    private func timeAgo(_ date: Date) -> String {
        let diff = Int(Date().timeIntervalSince(date))
        if diff < 3600 { return "\(diff / 60) min ago" }
        if diff < 86400 { return "\(diff / 3600) hours ago" }
        return "\(diff / 86400) days ago"
    }
}

#Preview {
    ProfileView(userId: "preview")
}
*/
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

            if vm.isLoading {
                ProgressView().tint(Color("palelime"))
            } else {
                VStack(spacing: 0) {
                    navBar
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 25) {
                            profileHeader
                            actionButtons
                            quickStats
                            performanceMetrics
                            archiveHistory
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .task { await vm.load() }
    }
}

// MARK: - Subviews
private extension ProfileView {

    var navBar: some View {
        HStack {
            Button { coordinator.goBack() } label: {
                Image(systemName: "line.3.horizontal")
            }
            Spacer()
            Text("VOLT_PROFILE")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
            Spacer()
            Image(systemName: vm.isOwnProfile ? "gearshape" : "bubble.right")
        }
        .foregroundColor(.white)
        .padding()
    }

    var profileHeader: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(colors: [.cyan, .clear], startPoint: .top, endPoint: .bottom),
                        lineWidth: 2
                    )
                    .frame(width: 130, height: 130)
                    .blur(radius: 2)

                Group {
                    if let urlStr = vm.profile?.profileImageUrl,
                       let url = URL(string: urlStr) {
                        KFImage(url)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(30)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            }

            VStack(spacing: 5) {
                Text(vm.displayName.isEmpty ? "—" : vm.displayName)
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)

                Text((vm.profile?.tier ?? "RECRUIT").uppercased())
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .kerning(1.5)
            }
        }
    }

    var actionButtons: some View {
        HStack(spacing: 15) {
            if vm.isOwnProfile {
                Button(action: {}) {
                    Text("EDIT PROFILE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("palelime"))
                }
            } else {
                Button { Task { await vm.toggleFollow() } } label: {
                    Text(vm.isFollowing ? "FOLLOWING" : "FOLLOW")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(vm.isFollowing ? Color(white: 0.3) : Color("palelime"))
                }

                Button(action: {}) {
                    Text("MESSAGE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.cyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.05))
                }
            }
        }
        .padding(.horizontal)
    }

    var quickStats: some View {
        HStack(spacing: 0) {
            statColumn(value: formatCount(vm.profile?.followersCount ?? 0), label: "FOLLOWERS")
            dividerLine
            statColumn(value: formatCount(vm.profile?.followingCount ?? 0), label: "FOLLOWING")
            dividerLine
            statColumn(value: "\(vm.profile?.trustScore ?? 0)", label: "TRUST SCORE", isBlue: true)
        }
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.03))
    }

    func statColumn(value: String, label: String, isBlue: Bool = false) -> some View {
        VStack(spacing: 5) {
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isBlue ? .cyan : .white)
                if isBlue {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.cyan)
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    var dividerLine: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 1, height: 30)
    }

    var performanceMetrics: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("PERFORMANCE_METRICS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
                .padding(.horizontal)

            VStack(spacing: 20) {
                HStack {
                    metricItem(label: "TOTAL SESSIONS", value: "\(vm.profile?.totalSessions ?? 0)", color: .cyan)
                    Spacer()
                    metricItem(label: "DISTANCE (KM)", value: formatDistance(vm.profile?.totalDistanceKm ?? 0), color: .white)
                }

                metricItem(label: "AVG. INTENSITY", value: "\(vm.profile?.avgIntensity ?? 0)%", color: .white)

                Divider().background(Color.white.opacity(0.1))

                HStack {
                    Text(lastActivityText)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(Color("palelime"))
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.05))
            .cornerRadius(4)
            .padding(.horizontal)
        }
    }

    func metricItem(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
        }
    }

    var archiveHistory: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("ARCHIVE_HISTORY")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                Spacer()
                Text("VIEW_ALL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.cyan)
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                archiveRow(title: "NEON_SPRINT_04", sub: "HIGH INTENSITY • 12.4KM", time: "2H AGO", icon: "bolt.fill", accent: Color("palelime"))
                archiveRow(title: "APEX_CLIMB_V3", sub: "ELEVATION • 850M GAIN", time: "YESTERDAY", icon: "mountain.2.fill", accent: .cyan)
                archiveRow(title: "SQUAD_DRILL_ALPHA", sub: "GROUP MISSION • 45MIN", time: "3D AGO", icon: "person.3.fill", accent: .gray)
            }
            .padding(.horizontal)
        }
    }

    func archiveRow(title: String, sub: String, time: String, icon: String, accent: Color) -> some View {
        HStack(spacing: 15) {
            Rectangle()
                .fill(accent)
                .frame(width: 3)

            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .background(Color.white.opacity(0.05))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(sub)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("COMPLETED")
                    .font(.system(size: 8, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                Text(time)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 65)
        .background(Color.white.opacity(0.03))
    }

    // MARK: - Helpers
    private var lastActivityText: String {
        guard let date = vm.profile?.lastActivityDate,
              let name = vm.profile?.lastActivityName else {
            return "No recent activity"
        }
        return "Last activity: \(timeAgo(date)) • \(name)"
    }

    private func formatCount(_ count: Int) -> String {
        count >= 1000 ? String(format: "%.1fK", Double(count) / 1000) : "\(count)"
    }

    private func formatDistance(_ km: Double) -> String {
        km >= 1000 ? String(format: "%.1fK", km / 1000) : String(format: "%.0f", km)
    }

    private func timeAgo(_ date: Date) -> String {
        let diff = Int(Date().timeIntervalSince(date))
        if diff < 3600 { return "\(diff / 60) min ago" }
        if diff < 86400 { return "\(diff / 3600) hours ago" }
        return "\(diff / 86400) days ago"
    }
}

#Preview {
    ProfileView(userId: "preview")
}

