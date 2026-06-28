//
//  PrivateEventSection.swift
//  sbud
//
//  Created by Erdal on 2.06.2026.
//

import SwiftUI
import Kingfisher

struct PrivateEventsSection: View {
    let events: [PrivateEvent]
    let isLoading: Bool
    let onTapEvent: (PrivateEvent) -> Void

    private let accent = Color(red: 1.0, green: 0.82, blue: 0.0) // gold

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(accent)
                Text("PRIVATE EVENTS")
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                Spacer()
            }

            if isLoading {
                HStack { ProgressView().tint(accent) }
                    .frame(maxWidth: .infinity).frame(height: 120)
            } else if events.isEmpty {
                Text("No private events from friends yet.")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(events) { event in
                            PrivateEventCard(event: event, accent: accent)
                                .onTapGesture { onTapEvent(event) }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding(20)
        .background(Color(white: 0.07))
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .padding(.horizontal, 16)
    }
}

struct PrivateEventCard: View {
    let event: PrivateEvent
    let accent: Color

    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(accent).frame(width: 3)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(event.activityType.uppercased())
                        .font(.system(size: 9, weight: .bold)).kerning(1.5)
                        .foregroundColor(accent)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("PRIVATE")
                            .font(.system(size: 9, weight: .bold)).kerning(1)
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(accent)
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
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
    }
}
