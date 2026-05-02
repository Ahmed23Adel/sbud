//
//  FriendHostRow.swift
//  sbud
//
//  Created by ahmed on 02/05/2026.
//

import SwiftUI
import Kingfisher

struct FriendHostRow: View {
    let item: FriendHostItem
    let accent: Color

    var body: some View {
        HStack(spacing: 0) {
            // Left accent bar
            Rectangle()
                .fill(accent)
                .frame(width: 3)

            HStack(spacing: 12) {
                // Avatar
                KFImage(URL(string: item.profile.profileImageUrl ?? ""))
                    .placeholder {
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                Text(item.profile.name.prefix(1).uppercased())
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundColor(.white.opacity(0.4))
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(stateColor.opacity(0.5), lineWidth: 1.5))

                // Name + status
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(item.profile.name) \(item.profile.surName)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    stateBadge
                }

                Spacer()

                // Action button
                actionButton
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    var stateBadge: some View {
        switch item.state {
        case .host:
            Label("HOST", systemImage: "checkmark.seal.fill")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.green)
        case .pending:
            Label("PENDING", systemImage: "clock.fill")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.yellow)
        case .rejected:
            Label("DECLINED", systemImage: "xmark.circle.fill")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.red.opacity(0.8))
        case .notInvited:
            Text("FRIEND")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.white.opacity(0.25))
        }
    }

    @ViewBuilder
    var actionButton: some View {
        switch item.state {
        case .notInvited:
            Button("INVITE") { /* call invite */ }
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(accent)
                .clipShape(RoundedRectangle(cornerRadius: 8))

        case .pending:
            Button("CANCEL") { /* cancel invite */ }
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.yellow)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.yellow.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.yellow.opacity(0.3), lineWidth: 1))

        case .host:
            Button("REMOVE") { /* remove host */ }
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.red.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red.opacity(0.2), lineWidth: 1))

        case .rejected:
            Button("RE-INVITE") { /* re-invite */ }
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var stateColor: Color {
        switch item.state {
        case .host:       return .green
        case .pending:    return .yellow
        case .rejected:   return .red.opacity(0.7)
        case .notInvited: return Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)
        }
    }
}
//
//#Preview {
//    FriendHostRow()
//}
