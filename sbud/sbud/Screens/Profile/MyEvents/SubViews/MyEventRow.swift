//
//  MyEventRow.swift
//  sbud
//
//  Created by ahmed on 30/04/2026.
//

import SwiftUI
import Kingfisher

struct MyEventRow: View {
    var event: UsersEvent
    // Off by default: the event-level unread/pending count belongs to the creator,
    // so it's only meaningful in the owner's own events list.
    var showNotifications: Bool = false
    @EnvironmentObject var coordinator: ProfileCoordinator

    private let teal = Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)

    var body: some View {
        HStack(spacing: 0) {

            Rectangle()
                .fill(stripeColor)
                .frame(width: 4)

            HStack(spacing: 12) {
                KFImage(URL(string: event.eventImage))
                    .placeholder {
                        Circle()
                            .fill(Color(white: 0.15))
                            .overlay(
                                Image(systemName: event.activityType.icon)
                                    .foregroundColor(event.status == .proposed ? Color("palelime") : teal)
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(teal.opacity(0.3), lineWidth: 1))

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: event.activityType.icon)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(event.status == .proposed ? Color("palelime") : teal)
                        Text(event.activityType.rawValue.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(event.status == .proposed ? Color("palelime") : teal)
                        Spacer()
                        statusBadge
                    }

                    Text(event.title.uppercased())
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                if showNotifications {
                    EventNotificationsBadge(eventId: event.eventId)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(white: 0.35))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
        }
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Status badge

    @ViewBuilder
    private var statusBadge: some View {
        if !event.isPublic {
            chipView(icon: "lock.fill", text: "PRIVATE", bg: Color("palelime"), fg: .black)
        }
    }

    private func chipView(icon: String? = nil, text: String, bg: Color, fg: Color) -> some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 8, weight: .bold))
            }
            Text(text)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .kerning(0.5)
        }
        .foregroundColor(fg)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(bg)
        .clipShape(Capsule())
    }

    // MARK: - Stripe color

    private var stripeColor: Color {
        switch event.status {
        case .proposed:  return Color("palelime")
        case .confirmed: return teal
        case .completed: return teal
        }
    }
}
