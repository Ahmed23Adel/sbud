//
//  UpcomingEventsSection.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import SwiftUI
import Kingfisher

enum CardColorScheme {
    case cyan, lime
    var accent: Color {
        switch self {
        case .cyan: return Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)
        case .lime: return Color("palelime")
        }
    }
}

struct UpcomingEventsSection: View {
    let events: [UpcomingEvent]
    let isLoading: Bool
    let onTapEvent: (UpcomingEvent) -> Void
    private let cyan = Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("UPCOMING EVENTS")
                    .font(.system(size: 15, weight: .black)).foregroundColor(.white)
                Spacer()
            }

            if isLoading {
                HStack { ProgressView().tint(cyan) }
                    .frame(maxWidth: .infinity).frame(height: 140)
            } else if events.isEmpty {
                Text("No upcoming events yet.")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray).frame(maxWidth: .infinity).padding(.vertical, 30)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                            UpcomingEventCard(event: event, colorScheme: index % 2 == 0 ? .cyan : .lime)
                                .onTapGesture { onTapEvent(event) }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding(20)
        .background(Color(white: 0.07))
        .padding(.horizontal, 16)
        .cornerRadius(4)
    }
}

struct UpcomingEventCard: View {
    let event: UpcomingEvent
    let colorScheme: CardColorScheme

    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(colorScheme.accent).frame(width: 3)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(event.activityType.uppercased())
                        .font(.system(size: 9, weight: .bold)).kerning(1.5)
                        .foregroundColor(colorScheme.accent)
                    Spacer()
                    Text(event.isConfirmed ? "CONFIRMED" : "PROPOSED")
                        .font(.system(size: 10, weight: .medium)).foregroundColor(.black)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(colorScheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Text(event.title.uppercased())
                    .font(.system(size: 13, weight: .black)).foregroundColor(.white)
                    .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text("DATE").font(.system(size: 9, weight: .bold)).kerning(1).foregroundColor(.gray)
                    Text(event.formattedDate).font(.system(size: 13, weight: .black)).foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 16)
            .frame(width: 260)
            .background(Color(red: 0.13, green: 0.13, blue: 0.13))
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
