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

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(event.usersEventStatus.color)
                .frame(width: 3)

            HStack(spacing: 12) {
                KFImage(URL(string: event.eventImage))
                    .placeholder {
                        Color.gray.opacity(0.3)
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: event.activityTypeEnum.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0))
                        Text(event.activityTypeEnum.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0))
                        Spacer()
                        Text("Host")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color("palelime"))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color("palelime").opacity(0.15))
                            .clipShape(Capsule())
                    }
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .onTapGesture { onTap() }
    }
}
