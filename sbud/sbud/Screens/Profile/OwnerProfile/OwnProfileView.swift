//
//  OwnProfileView.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//
import SwiftUI
import Kingfisher

struct OwnProfileView: View {
    @StateObject private var vm: OwnProfileVM
    @EnvironmentObject var coordinator: ProfileCoordinator

    @State private var currentPage = 0
    @State private var showPhotoPreview = false
    @State private var showEditProfile = false

    init(userId: String) {
        _vm = StateObject(wrappedValue: OwnProfileVM(userId: userId))
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
                            ProfilePageIndicator(currentPage: currentPage, pageCount: 2)
                            editButton
                            ProfileStatsRow(
                                friendsCount: vm.profile?.friendsCount ?? 0,
                                onFriendsTap: { coordinator.goToFriendsList() }
                            )
                            .accessibilityIdentifier("profile.friendsStatsButton")
                            if let profile = vm.profile {
                                ProfilePerformanceCard(profile: profile)
                            }
                            AthleteFeedbackSection(
                                isOwnProfile: true,
                                topFeedbacks: vm.profile?.top10Feedbacks ?? []
                            )

                            ProfileMyEventsButton(userId: vm.userId, title: "MY EVENTS") {
                                coordinator.goToMyEvents()
                            }
                            .accessibilityIdentifier("profile.myEventsButton")
                        }
                        .padding(.bottom, 80)
                    }
                }
            }

            // QR code floating button (from main)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    BasicFloatingButton(iconName: "qrcode") {
                        coordinator.showQRCode()
                    }
                    .accessibilityIdentifier("profile.qrCodeButton")
                }
            }

            // Photo preview overlay (from HEAD)
            if showPhotoPreview {
                photoPreviewOverlay
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showPhotoPreview)
        .task { await vm.load() }
        .fullScreenCover(isPresented: $showEditProfile) {
            EditProfileView(profile: vm.profile) { updatedProfile in
                vm.profile = updatedProfile
            }
        }
    }
}

// MARK: - Subviews

private extension OwnProfileView {

    var navBar: some View {
        HStack {
            Color.clear.frame(width: 44, height: 44)
            Spacer()
            HStack(spacing: 16) {
                // Friend requests button with notification badge (from main)
                NumberedButtonNotifications(
                    onTapGestureFunc: coordinator.goToFriendRequests,
                    buttonIcon: "person.badge.clock",
                    pendingRequestCount: $vm.pendingFriendsRequestCount)
                .accessibilityIdentifier("profile.friendRequestsButton")

                // Host requests button (from main)
                NumberedButtonNotifications(
                    onTapGestureFunc: coordinator.goToHostRequests,
                    buttonIcon: "person.2.wave.2",
                    pendingRequestCount: $vm.pendingHostsRequestCount)
                .accessibilityIdentifier("profile.hostRequestsButton")

                Button {
                    shareProfile(userId: vm.userId)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .accessibilityIdentifier("profile.shareButton")

                Button {
                    coordinator.goToSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .accessibilityIdentifier("profile.settingsButton")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05))
    }

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
            showEmail: true,
            showPhone: true
        )
    }

    func shareProfile(userId: String) {
        guard let url = URL(string: "https://sbud-backend.onrender.com/profile/\(userId)") else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?
            .present(av, animated: true)
    }

    var editButton: some View {
        Button(action: { showEditProfile = true }) {
            Text("EDIT PROFILE")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color("palelime"))
                .cornerRadius(12)
        }
        .padding(.horizontal, 24)
        .accessibilityIdentifier("profile.editButton")
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
//    OwnProfileView(userId: "preview-own-user")
//        .environmentObject(ProfileCoordinator(userId: "preview"))
//}

