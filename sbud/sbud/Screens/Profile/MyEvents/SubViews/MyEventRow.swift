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
    @EnvironmentObject var coordinator: ProfileCoordinator
    
    private let accent = Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)

    var body: some View {
        HStack(spacing: 0) {
            // Left accent bar colored by status
            Rectangle()
                .fill(statusColor)
                .frame(width: 3)

            HStack(spacing: 12) {
                // Event image
                KFImage(URL(string: event.eventImage))
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(accent.opacity(0.4), lineWidth: 1.5))

                VStack(alignment: .leading, spacing: 4) {
                    // Activity type row
                    HStack(spacing: 6) {
                        Image(systemName: event.activityType.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accent)
                        Text(event.activityType.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accent)
                        Spacer()
                        
                    }

                    // Title
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                }

                Spacer()
                
                EventUnreadBadge(eventId: event.eventId)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))

    }

    private var statusColor: Color {
        switch event.status {
        case .proposed:  return .yellow
        case .confirmed: return Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)
        case .completed: return .green
        }
    }
}
//
//#Preview {
//    MyEventRow(event: UsersEvent())
//}
