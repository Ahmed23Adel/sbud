//
//  MainAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//

import SwiftUI

struct MainAppCoordinator: View {
    @StateObject private var coordinator = MainCoordinator()
    
    var body: some View {
        ZStack {
            // Main content
            Group {
                switch coordinator.currentRoute {
                case .homePage:
                    HomeTabsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                        .ignoresSafeArea()
                case .signUp:
                    SignUpView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                        .ignoresSafeArea()
                case .signIn:
                    SignInView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                        .ignoresSafeArea()
                case .profileSetup:
                    ProfileSetupView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                        .ignoresSafeArea()
                case .loadingPage:
                    LoadingView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                        .ignoresSafeArea()
                case .profilePage(let userId):
                    ProfileView(userId: userId)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                case .settingsPage:
                    SettingsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                        .ignoresSafeArea()
                case .followerList(let userId):
                    FollowListView(userId: userId, mode: .followers)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                case .followingList(let userId):
                    FollowListView(userId: userId, mode: .following)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                case .friendRequests:
                    FriendRequestsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: coordinator.currentRoute)
            .environmentObject(coordinator)
            
            VStack{
                Spacer()
                PopUpStackView()
                    .padding()
            }
            
        }
    }
}

#Preview {
    MainAppCoordinator()
}
