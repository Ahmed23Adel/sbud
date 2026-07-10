//
//  HostingEventRow.swift
//  sbud
//
//  Created by Erdal on 17.05.2026.
//

import SwiftUI
import Kingfisher

struct HostingEventRow: View {
    let event: HostingEvent
    let onTap: () -> Void

    private let teal = Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)

    var body: some View {
        HStack(spacing: 0) {

            Rectangle()
                .fill(event.usersEventStatus.color)
                .frame(width: 4)

            HStack(spacing: 12) {
                KFImage(URL(string: event.eventImage))
                    .placeholder {
                        Circle()
                            .fill(Color(white: 0.15))
                            .overlay(
                                Image(systemName: event.activityTypeEnum.icon)
                                    .foregroundColor(teal.opacity(0.5))
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(teal.opacity(0.3), lineWidth: 1))

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: event.activityTypeEnum.icon)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(teal)
                        Text(event.activityTypeEnum.rawValue.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(teal)
                        Spacer()
                        HStack(spacing: 4) {
                            Text("HOSTED")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .kerning(0.5)
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("palelime"))
                        .clipShape(Capsule())
                    }

                    Text(event.title.uppercased())
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
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
        .onTapGesture { onTap() }
    }
}

