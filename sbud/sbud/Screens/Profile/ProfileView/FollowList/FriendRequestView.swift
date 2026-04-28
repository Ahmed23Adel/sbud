//
//  FriendRequestView.swift
//  sbud
//
//  Created by Erdal on 28.04.2026.
//

import SwiftUI
import Kingfisher

struct FriendRequestsView: View {
    @StateObject private var vm = FriendRequestsVM()
    @EnvironmentObject var coordinator: MainCoordinator

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: NavBar
                HStack {
                    Button { coordinator.goBack() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("FRIEND REQUESTS")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .kerning(1.5)
                    Spacer()
                    Color.clear.frame(width: 28, height: 28)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)

                Divider().background(Color(white: 0.12))

                // MARK: Content
                if vm.isLoading {
                    Spacer()
                    ProgressView().tint(Color("palelime"))
                    Spacer()
                } else if vm.requests.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 36))
                            .foregroundColor(Color(white: 0.25))
                        Text("No pending requests.")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.requests) { user in
                                RequestCell(user: user, vm: vm)
                                Divider().background(Color(white: 0.1))
                            }
                        }
                    }
                }
            }
        }
        .task { await vm.load() }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}

// MARK: - Request Cell
private struct RequestCell: View {
    let user: UserProfile
    @ObservedObject var vm: FriendRequestsVM
    @EnvironmentObject var coordinator: MainCoordinator

    var displayName: String {
        let last = user.surName.first.map { "\($0)." } ?? ""
        return "\(user.name.uppercased())_\(last.uppercased())"
            .trimmingCharacters(in: .init(charactersIn: "_"))
    }

    var body: some View {
        HStack(spacing: 14) {
            // Avatar — profile'a git
            Group {
                if let urlStr = user.profileImageUrl, let url = URL(string: urlStr) {
                    KFImage(url)
                        .placeholder { Circle().fill(Color(white: 0.15)) }
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle().fill(Color(white: 0.15))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 18))
                        )
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(white: 0.2), lineWidth: 1))
            .onTapGesture { coordinator.goToProfile(userId: user.id) }

            // İsim + bio
            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Accept / Decline
            HStack(spacing: 10) {
                // Decline — X
                Button {
                    Task { await vm.decline(user) }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(width: 38, height: 38)
                        .background(Color(white: 0.12))
                        .clipShape(Circle())
                }

                // Accept — ✓
                Button {
                    Task { await vm.accept(user) }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 38, height: 38)
                        .background(Color("palelime"))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
