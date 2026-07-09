//
//  RecommendedEventsSection.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import SwiftUI
import Kingfisher

struct RecommendedEventsSection: View {
    let events: [RecommendedEvent]
    let isLoading: Bool
    let onTapEvent: (RecommendedEvent) -> Void
    let onJoin: (RecommendedEvent) -> Void

    @State private var currentPage = 0
    @State private var autoScrollTimer: Timer? = nil

    private let lime = Color("palelime")
    private let skyBlue = Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)
    private let autoScrollInterval: TimeInterval = 3.5

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                PageSectionTitle(title: "RECOMMENDED EVENTS")
                Spacer()
            }

            if isLoading {
                RecommendedSkeletonCard()
            } else if events.isEmpty {
                Text("No recommended events yet.")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else {
                VStack(spacing: 12) {

                    TabView(selection: $currentPage) {
                        ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                            RecommendedEventCard(
                                event: event,
                                accentColor: index % 2 == 0 ? lime : skyBlue,
                                onTap: { onTapEvent(event) },
                                onJoin: { onJoin(event) }
                            )
                            .tag(index)
                            .padding(.horizontal, 4)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 320)
                    .animation(.easeInOut(duration: 0.4), value: currentPage)

                    HStack(spacing: 6) {
                        ForEach(0..<max(1, events.count), id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? lime : Color.white.opacity(0.25))
                                .frame(width: i == currentPage ? 20 : 6, height: 6)
                                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .onAppear { startAutoScroll() }
                .onDisappear { stopAutoScroll() }
            }
        }
        .padding(20)
        .background(Color(white: 0.07))
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .padding(.horizontal, 16)
    }

    // MARK: - Auto Scroll
    private func startAutoScroll() {
        stopAutoScroll()
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
            guard !events.isEmpty else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPage = (currentPage + 1) % events.count
            }
        }
    }

    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
}

// MARK: - Card

struct RecommendedEventCard: View {
    let event: RecommendedEvent
    let accentColor: Color
    let onTap: () -> Void
    let onJoin: () -> Void

    private let cardHeight: CGFloat = 300

    var body: some View {
        Rectangle()
            .fill(Color(white: 0.12))
            .frame(height: cardHeight)
            .overlay(
                KFImage(URL(string: event.eventImage))
                    .placeholder {
                        Rectangle()
                            .fill(Color(white: 0.12))
                            .overlay(ProgressView().tint(accentColor))
                    }
                    .resizable()
                    .scaledToFill()
                    .clipped()
            )
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black.opacity(0.5), location: 0.55),
                        .init(color: .black.opacity(0.97), location: 1)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .overlay(
                VStack(alignment: .leading, spacing: 12) {
                    Text(event.activityType.uppercased())
                        .font(.system(size: 10, weight: .black)).kerning(1)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(accentColor).foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Text(event.title.uppercased())
                        .font(.system(size: 24, weight: .black)).foregroundColor(.white)
                        .lineLimit(2).multilineTextAlignment(.leading)

                    if !event.notes.isEmpty {
                        Text(event.notes)
                            .font(.system(size: 13)).foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }

                    Button(action: { if !event.hasJoined { onJoin() } }) {
                        Text(event.joinButtonLabel)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(event.hasJoined ? .white.opacity(0.5) : .black)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(event.hasJoined ? Color.gray.opacity(0.4) : accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain).disabled(event.hasJoined)
                }
                .padding(20),
                alignment: .bottomLeading
            )
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: UIConstants.cornerRadius).stroke(accentColor.opacity(0.4), lineWidth: 1))
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .onTapGesture { onTap() }
    }
}

