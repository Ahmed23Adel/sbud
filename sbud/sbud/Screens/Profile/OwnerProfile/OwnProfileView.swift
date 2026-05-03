//
//  OwnProfileView.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//
import SwiftUI

struct OwnProfileView: View {
    @StateObject private var vm: OwnProfileVM
    @EnvironmentObject var coordinator: ProfileCoordinator

    @State private var currentPage = 0

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
                                onFriendsTap: {
                                    coordinator.goToFriendsList()
                                }
                            )
                            if let profile = vm.profile {
                                ProfilePerformanceCard(profile: profile)
                            }
                            ProfileArchiveSection()
                            ProfileMyEventsButton(userId: vm.userId) {
                                coordinator.goToMyEvents()
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

private extension OwnProfileView {

    var navBar: some View {
        HStack {
            Color.clear.frame(width: 44, height: 44)
            Spacer()
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
                Button {
                    coordinator.goToSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
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

    // Own profile always sees all fields — ProfileUtils.canShow* not needed here
    var detailHeaderContent: some View {
        ProfileDetailHeader(
            profile: vm.profile ?? .empty,
            showEmail: true,
            showPhone: true
        )
    }

    var editButton: some View {
        Button(action: { print("edit profile")}) {
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
}

#Preview {
    OwnProfileView(userId: "preview-own-user")
        .environmentObject(MainCoordinator())
}
