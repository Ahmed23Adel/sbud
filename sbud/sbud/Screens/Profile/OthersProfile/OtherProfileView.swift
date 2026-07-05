//
//  OtherProfileView.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI
import Kingfisher

struct OtherProfileView: View {
    @StateObject private var vm: OtherProfileVM
    @EnvironmentObject var coordinator: ProfileCoordinator

    @State private var currentPage = 0
    @State private var showPhotoPreview = false

    init(userId: String, onBack: (() -> Void)? = nil) {
        _vm = StateObject(wrappedValue: OtherProfileVM(userId: userId))
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 0) {
                if vm.isLoading {
                    Spacer()
                    ProgressView().tint(Color("palelime"))
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            headerTabView
                            ProfilePageIndicator(currentPage: currentPage, pageCount: 2)
                            followButton
                            ProfileStatsRow(
                                friendsCount: vm.profile?.friendsCount ?? 0,
                                onFriendsTap: { coordinator.goToFriendsList() }
                            )
                            if let profile = vm.profile {
                                ProfilePerformanceCard(profile: profile)
                            }
                            ProfileMyEventsButton(userId: vm.userId, title: "EVENTS") {
                                print("goToOthersEvents")
                                coordinator.goToOthersEvents()
                            }
                        }
                        .padding(.bottom, 80)
                    }
                }
            }

            if showPhotoPreview {
                photoPreviewOverlay
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showPhotoPreview)
        .task { await vm.load() }
    }
}

// MARK: - Subviews

private extension OtherProfileView {

    var headerTabView: some View {
        TabView(selection: $currentPage) {
            mainHeaderContent.tag(0)
            detailHeaderContent.tag(1)
        }
        .frame(height: 280)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    var mainHeaderContent: some View {
        VStack(spacing: 12) {
            avatarCircle
            Text("\(vm.profile?.name ?? "") \(vm.profile?.surName ?? "")".uppercased())
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.white)
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

    var avatarCircle: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                showPhotoPreview = true
            }
        } label: {
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
                            .padding(28)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 110, height: 110)
                .clipShape(Circle())
            }
        }
        .buttonStyle(.plain)
    }

    var detailHeaderContent: some View {
        ProfileDetailHeader(
            profile: vm.profile ?? .empty,
            showEmail: ProfileUtils.canShowEmail(
                profile: vm.profile ?? .empty,
                isFriend: vm.isFriend,
                isOwnProfile: false
            ),
            showPhone: ProfileUtils.canShowPhone(
                profile: vm.profile ?? .empty,
                isFriend: vm.isFriend,
                isOwnProfile: false
            )
        )
    }

    var followButton: some View {
        HStack(spacing: 10) {
            Button {
                Task { await vm.toggleFriendAction() }
            } label: {
                ZStack {
                    if vm.isFriendActionLoading {
                        ProgressView().tint(friendActionForeground)
                    } else {
                        HStack(spacing: 6) {
                            if vm.isRequestSent || vm.isRequestReceived {
                                Image(systemName: "clock")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            Text(friendActionLabel)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(friendActionForeground)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(friendActionBackground)
                .clipShape(Rectangle())
                .cornerRadius(4)
            }

            Button {
                shareProfile(userId: vm.userId)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color(white: 0.15))
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal, 24)
    }

    func shareProfile(userId: String) {
        guard let url = URL(string: "https://sbud-backend.onrender.com/profile/\(userId)") else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?
            .present(av, animated: true)
    }

    private var friendActionLabel: String {
        switch vm.friendStatus {
        case .friends:         return "UNFRIEND"
        case .requestSent:     return "REQUESTED"
        case .requestReceived: return "ACCEPT"
        case .notFriend:       return "ADD FRIEND"
        }
    }

    private var friendActionForeground: Color {
        switch vm.friendStatus {
        case .friends, .requestSent:       return .white
        case .requestReceived, .notFriend: return .black
        }
    }

    private var friendActionBackground: Color {
        switch vm.friendStatus {
        case .friends:         return Color(white: 0.2)
        case .requestSent:     return Color(white: 0.25)
        case .requestReceived: return Color("palelime")
        case .notFriend:       return Color("palelime")
        }
    }
    var photoPreviewOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.6))
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showPhotoPreview = false
                    }
                }

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color("turquoise"), Color("turquoise").opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 286, height: 286)
                        .shadow(color: Color("turquoise").opacity(0.55), radius: 28)

                    Group {
                        if let urlStr = vm.profile?.profileImageUrl, let url = URL(string: urlStr) {
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(60)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 272, height: 272)
                    .clipShape(Circle())
                }
                .scaleEffect(showPhotoPreview ? 1 : 0.35)
                .animation(.spring(response: 0.45, dampingFraction: 0.72), value: showPhotoPreview)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showPhotoPreview = false
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.13))
                            .frame(width: 54, height: 54)
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 52)
            }
        }
    }
}


//#Preview {
//    OtherProfileView(userId: "preview-other-user")
//        .environmentObject(MainCoordinator())
//}
//#Preview {
//    OtherProfileView()
//}
