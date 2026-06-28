//
//  FriendListView.swift
//  sbud
//
//  Created by Erdal on 29.04.2026.
//

import SwiftUI
import Kingfisher
struct FriendListView: View {
    @StateObject private var vm: FriendListVM
    let onSelectUser: (String) -> Void

    init(userId: String, onSelectUser: @escaping (String) -> Void) {
        _vm = StateObject(wrappedValue: FriendListVM(userId: userId))
        self.onSelectUser = onSelectUser
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 0) {

                // Title at top
                Text("FRIENDS")
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .kerning(1.5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.05, green: 0.05, blue: 0.05))

                Divider().background(Color(white: 0.12))

                if vm.isLoading {
                    Spacer()
                    ProgressView().tint(Color("palelime"))
                    Spacer()
                } else if vm.users.isEmpty {
                    Spacer()
                    Text("No friends yet.")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.users) { user in
                                UserRowCell(user: user)
                                    .onTapGesture {
                                        onSelectUser(user.id)
                                    }

                                Divider().background(Color(white: 0.1))
                            }
                        }
                    }
                }
            }
        }
        .task { await vm.load() }
    }
}

// MARK: - User Row Cell
private struct UserRowCell: View {
    let user: UserProfile

    var displayName: String {
        let last = user.surName.first.map { "\($0)." } ?? ""
        let full = "\(user.name.uppercased())_\(last.uppercased())"
            .trimmingCharacters(in: .init(charactersIn: "_"))
        return full.isEmpty ? "—" : full
    }

    var body: some View {
        HStack(spacing: 14) {
            Group {
                if let urlStr = user.profileImageUrl, let url = URL(string: urlStr) {
                    KFImage(url)
                        .placeholder {
                            Circle().fill(Color(white: 0.15))
                        }
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle()
                        .fill(Color(white: 0.15))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 18))
                        )
                }
            }
            .frame(width: 46, height: 46)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(white: 0.2), lineWidth: 1))

            VStack(alignment: .leading, spacing: 3) {
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

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(white: 0.3))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05))
        .contentShape(Rectangle())
    }
}

