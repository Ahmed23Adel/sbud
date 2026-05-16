//
//  FriendHostRow.swift
//  sbud
//

import SwiftUI
import Kingfisher

struct FriendHostRow: View {
    let item: FriendHostItem
    let accent: Color
    let onInvite:   () -> Void
    let onCancel:   () -> Void
    let onRemove:   () -> Void
    let onReInvite: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(stateColor)
                .frame(width: 3)

            HStack(spacing: 12) {
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

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(item.profile.name) \(item.profile.surName)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    stateBadge
                }

                Spacer()
                actionButton
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private var stateBadge: some View {
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
    private var actionButton: some View {
        switch item.state {
        case .notInvited:
            Button("INVITE", action: onInvite)
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(accent)
                .clipShape(RoundedRectangle(cornerRadius: 8))

        case .pending:
            Button("CANCEL", action: onCancel)
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.yellow)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.yellow.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.yellow.opacity(0.3), lineWidth: 1))

        case .host:
            Button("REMOVE", action: onRemove)
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(.red.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red.opacity(0.2), lineWidth: 1))

        case .rejected:
            Button("RE-INVITE", action: onReInvite)
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
        case .notInvited: return .mainColor
        }
    }
}
