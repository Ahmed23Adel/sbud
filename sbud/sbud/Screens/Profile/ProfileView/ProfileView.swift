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
    
    @State private var currentPage = 0
    
    var onBack: (() -> Void)? = nil

    init(userId: String, onBack: (() -> Void)? = nil) {
        _vm = StateObject(wrappedValue: ProfileVM(userId: userId))
        self.onBack = onBack
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
                            headerTabView
                            pageIndicator

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


private extension ProfileView {
    
    var headerTabView: some View {
        TabView(selection: $currentPage) {
            mainHeaderContent
                .tag(0)
            
            detailHeaderContent
                .tag(1)
        }
        .frame(height: 280)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    var mainHeaderContent: some View {
        VStack(spacing: 12) {
            avatarCircle
            
            VStack(spacing: 4) {
                Text("\(vm.profile?.name ?? "") \(vm.profile?.surName ?? "")".uppercased())
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
            }
            
            if let bio = vm.profile?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineLimit(3)
            }
        }
    }
    
    var detailHeaderContent: some View {
        VStack(alignment: .leading, spacing: 18) {

            if vm.isOwnProfile || ((vm.profile?.showEmail ?? false) && vm.isFriend) {
                infoRow(icon: "envelope", label: "EMAIL", value: vm.profile?.email ?? "")
            }

            if vm.isOwnProfile || ((vm.profile?.showPhone ?? false) && vm.isFriend) {
                infoRow(icon: "phone", label: "PHONE", value: vm.profile?.phoneNumber ?? "")
            }
            
            infoRow(icon: "calendar",
                    label: "AGE",
                    value: "\(vm.profile?.age ?? 0) YEARS")
            
            infoRow(icon: "person", label: "GENDER", value: vm.profile?.gender ?? "")
            
            infoRow(
                icon: "mappin.and.ellipse",
                label: "LOCATION",
                value: "\(vm.profile?.city ?? ""), \(vm.profile?.country ?? "")"
            )
        }
        .padding(.horizontal, 40)
    }
    
    func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color("turquoise"))
                .frame(width: 28, height: 28)
                .offset(y: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                Text(value.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
    }
    var avatarCircle: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Circle()
                    .stroke(Color("turquoise").opacity(0.5), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .shadow(color: Color("turquoise").opacity(0.3), radius: 10)

                Group {
                    if let urlStr = vm.profile?.profileImageUrl, let url = URL(string: urlStr) {
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
                .frame(width: 110, height: 110)
                .clipShape(Circle())
            }
        }
        .padding(.bottom, 10)
    }

    var pageIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(currentPage == 0 ? Color("palelime") : Color.gray.opacity(0.5))
                .frame(width: 6, height: 6)
            Circle()
                .fill(currentPage == 1 ? Color("palelime") : Color.gray.opacity(0.5))
                .frame(width: 6, height: 6)
        }
    }

    var editButton: some View {
        Button(action: {}) {
            Text("EDIT PROFILE")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color("palelime"))
                .cornerRadius(12)
        }
        .padding(.horizontal, 24)
    }
    
    var navBar: some View {
        HStack {
            if onBack != nil {
                Button { onBack?() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            } else if coordinator.canGoBack {
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
                HStack(spacing: 16) {
                    Button { coordinator.goToFriendRequests() } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "person.badge.clock")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            if vm.pendingRequestCount > 0 {
                                Text("\(vm.pendingRequestCount)")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundColor(.black)
                                    .padding(3)
                                    .background(Color("palelime"))
                                    .clipShape(Circle())
                                    .offset(x: 6, y: -6)
                            }
                        }
                    }
                    Button { coordinator.goToSettings() } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05))
    }
    
    var followButtons: some View {
        Button {
            Task { await vm.toggleFriendAction() }
        } label: {
            ZStack {
                if vm.isFriendActionLoading {
                    ProgressView().tint(friendActionButtonForeground)
                } else {
                    HStack(spacing: 6) {
                        if vm.isRequestSent || vm.isRequestReceived {
                            Image(systemName: "clock")
                                .font(.system(size: 12, weight: .bold))
                        }
                        Text(friendActionButtonLabel)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(friendActionButtonForeground)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(friendActionButtonBackground)
            .clipShape(Rectangle())
            .cornerRadius(4)
        }
        .padding(.horizontal, 24)
    }

    private var friendActionButtonLabel: String {
        switch vm.friendStatus {
        case .friends:         return "UNFRIEND"
        case .requestSent:     return "REQUESTED"
        case .requestReceived: return "ACCEPT"
        case .notFriend:       return (vm.profile?.isPrivate ?? false) ? "ADD FRIEND" : "ADD FRIEND"
        }
    }

    private var friendActionButtonForeground: Color {
        switch vm.friendStatus {
        case .friends:         return .white
        case .requestSent:     return .white
        case .requestReceived: return .black
        case .notFriend:       return .black
        }
    }

    private var friendActionButtonBackground: Color {
        switch vm.friendStatus {
        case .friends:         return Color(white: 0.2)
        case .requestSent:     return Color(white: 0.25)
        case .requestReceived: return Color("palelime")
        case .notFriend:       return Color("palelime")
        }
    }

    var statsRow: some View {
        HStack(spacing: 0) {
            Button {
                coordinator.goToFriendList(userId: vm.userId)
            } label: {
                statItem(value: formatCount(vm.profile?.friendsCount ?? 0), label: "FRIENDS")
            }
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



