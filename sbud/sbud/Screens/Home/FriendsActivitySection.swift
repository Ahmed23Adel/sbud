//
//  FriendsActivitySection.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import SwiftUI
import Kingfisher

struct FriendsActivitySection: View {
    let items: [FriendActivityItem]
    let isLoading: Bool
    let onTapProfile: (String) -> Void
    let onTapEvent: (FriendActivityItem) -> Void

    @State private var currentPage = 0
    private let cyan = Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)

    private var pages: [[FriendActivityItem]] {
        let limited = Array(items.prefix(6))
        if limited.isEmpty { return [] }
        return stride(from: 0, to: limited.count, by: 2).map {
            Array(limited[$0..<min($0 + 2, limited.count)])
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                Text("BUDDY MOVES")
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                Spacer()
            }

            if isLoading {
                loadingPlaceholder
            } else if items.isEmpty {
                emptyState
            } else {
                VStack(spacing: 10) {
                    if pages.count <= 1 {
                        rowsView(pageItems: pages[0])
                    } else {
                        TabView(selection: $currentPage) {
                            ForEach(Array(pages.enumerated()), id: \.offset) { pageIndex, pageItems in
                                rowsView(pageItems: pageItems)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                    .tag(pageIndex)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 144)
                    }

                    
                    if pages.count > 1 {
                        HStack(spacing: 6) {
                            ForEach(0..<pages.count, id: \.self) { i in
                                Circle()
                                    .fill(i == currentPage ? cyan : Color.white.opacity(0.2))
                                    .frame(width: i == currentPage ? 8 : 6,
                                           height: i == currentPage ? 8 : 6)
                                    .animation(.easeInOut(duration: 0.2), value: currentPage)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(20)
        .background(Color(white: 0.07))
        .padding(.horizontal, 16)
        .cornerRadius(4)
    }

    // MARK: - Rows View (ayırıcı çizgili)
    @ViewBuilder
    private func rowsView(pageItems: [FriendActivityItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(pageItems.enumerated()), id: \.element.id) { index, item in
                friendRow(item: item)
            
                if index < pageItems.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 1)
                        .padding(.leading, 56)
                }
            }
        }
    }

    // MARK: - Friend Row
    @ViewBuilder
    private func friendRow(item: FriendActivityItem) -> some View {
        HStack(spacing: 12) {
            KFImage(item.profileImageUrl.flatMap { URL(string: $0) })
                .placeholder {
                    Circle().fill(Color.gray.opacity(0.3))
                        .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                }
                .resizable().scaledToFill()
                .frame(width: 44, height: 44).clipShape(Circle())
                .overlay(Circle().stroke(cyan.opacity(0.4), lineWidth: 1.5))
                .onTapGesture { onTapProfile(item.userId) }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(item.eventTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(cyan.opacity(0.8))
                    .lineLimit(1)
                Text(item.roleLabel)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(item.roleColor)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.35))
                .padding(.trailing, 10)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { onTapEvent(item) }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        Text("Your friends' activity will appear here.")
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
    }

    // MARK: - Loading Placeholder
    private var loadingPlaceholder: some View {
        VStack(spacing: 0) {
            ForEach(0..<2, id: \.self) { i in
                HStack(spacing: 12) {
                    Circle().fill(Color(white: 0.1)).frame(width: 44, height: 44)
                    VStack(alignment: .leading, spacing: 4) {
                        RoundedRectangle(cornerRadius: 4).fill(Color(white: 0.1)).frame(width: 100, height: 12)
                        RoundedRectangle(cornerRadius: 4).fill(Color(white: 0.1)).frame(width: 140, height: 10)
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                if i < 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 1)
                        .padding(.leading, 56)
                }
            }
        }
    }
}
