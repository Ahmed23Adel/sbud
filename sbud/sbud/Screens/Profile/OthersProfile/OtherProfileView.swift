//
//  OtherProfileView.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct OtherProfileView: View {
    @StateObject private var vm: OtherProfileVM
    @EnvironmentObject var coordinator: ProfileCoordinator

    @State private var currentPage = 0

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
                                onFriendsTap: {
                                    coordinator.goToFriendsList()
                                }
                            )
                            if let profile = vm.profile {
                                ProfilePerformanceCard(profile: profile)
                            }
                            ProfileArchiveSection()
                            ProfileMyEventsButton(userId: vm.userId) {
                                coordinator.goToAppropiateEvents()
                            }
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
            ProfileAvatarView(imageUrl: vm.profile?.profileImageUrl)
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

    // Privacy-gated via ProfileUtils — centralised logic, not inline
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
        .padding(.horizontal, 24)
    }

    // MARK: - Friend button appearance (derived from VM state, no logic)

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
}

//#Preview {
//    OtherProfileView(userId: "preview-other-user")
//        .environmentObject(MainCoordinator())
//}
//#Preview {
//    OtherProfileView()
//}
