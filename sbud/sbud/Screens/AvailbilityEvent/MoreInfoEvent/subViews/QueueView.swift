//
//  QueueView.swift
//  sbud
//
//  Created by Erdal on 3.05.2026.
//

import SwiftUI
import Kingfisher

struct QueueView: View {
    let queueResponse: JoinQueueResponse
    let isLoading: Bool
    let onRespond: (_ requesterId: String, _ accept: Bool) -> Void
    let onDismiss: () -> Void
    let onTapProfile: (_ userId: String) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var cardRotation: Double = 0

    private var current: PendingRequester? { queueResponse.pendingUsers.first }
    private var isFull: Bool { queueResponse.isCapacityFull }

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            VStack(spacing: 0) {

                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.backgroundColor)
                            .clipShape(Circle())
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("Join Requests")
                            .font(.headline).foregroundColor(.white)
                        capacityLabel
                    }
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding()

                if isFull {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.black)
                        Text("Capacity full — cannot accept more requests")
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 10).padding(.horizontal, 16)
                    .background(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                Spacer()

                if isLoading {
                    ProgressView().tint(Color.mainColor)
                } else if let user = current {
                    requesterCard(user: user)
                        .offset(dragOffset)
                        .rotationEffect(.degrees(cardRotation))
                        .gesture(
                            DragGesture()
                                .onChanged { val in
                                    dragOffset = val.translation
                                    cardRotation = Double(val.translation.width / 20)
                                }
                                .onEnded { val in
                                    let threshold: CGFloat = 100
                                    if val.translation.width > threshold && !isFull {
                                        swipe(accept: true, user: user)
                                    } else if val.translation.width < -threshold {
                                        swipe(accept: false, user: user)
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = .zero
                                            cardRotation = 0
                                        }
                                    }
                                }
                        )
                        .animation(.spring(response: 0.3), value: dragOffset)
                } else {
                    emptyState
                }

                Spacer()

                if let user = current {
                    actionButtons(user: user)
                        .padding(.bottom, 32)
                }
            }
        }
    }

    private func requesterCard(user: PendingRequester) -> some View {
        ZStack(alignment: .bottom) {

            Group {
                if let urlStr = user.profileImageUrl, let url = URL(string: urlStr) {
                    KFImage(url)
                        .placeholder {
                            Color.gray.opacity(0.3)
                                .overlay(Image(systemName: "person.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray))
                        }
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.3)
                        .overlay(Image(systemName: "person.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray))
                }
            }
            .frame(width: 300, height: 420)
            .clipped()

            VStack(spacing: 0) {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.75)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 140)
                .overlay(
                    Text(user.fullName)
                        .font(.title).fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 12),
                    alignment: .bottom
                )
            }

            RoundedRectangle(cornerRadius: 24)
                .fill(swipeOverlayColor)
                .animation(.easeInOut(duration: 0.1), value: dragOffset)
        }
        .frame(width: 300, height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
        .onTapGesture {
            onTapProfile(user.userId)
        }
    }

    private func actionButtons(user: PendingRequester) -> some View {
        HStack(spacing: 40) {

            Button {
                swipe(accept: false, user: user)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Color.red.opacity(0.85))
                    .clipShape(Circle())
                    .shadow(radius: 6)
            }

            Button {
                if !isFull { swipe(accept: true, user: user) }
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 64, height: 64)
                    .background(isFull ? Color.gray.opacity(0.4) : Color.mainColor)
                    .clipShape(Circle())
                    .shadow(radius: 6)
            }
            .disabled(isFull)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No pending requests")
                .font(.title3).foregroundColor(.gray)
            if queueResponse.waitlistCount > 0 {
                Text("\(queueResponse.waitlistCount) on waitlist")
                    .font(.subheadline).foregroundColor(.gray.opacity(0.7))
            }
        }
    }

    private var capacityLabel: some View {
        let confirmed = queueResponse.confirmedCount
        let cap = queueResponse.capacity ?? 0
        let pending = queueResponse.pendingCount
        let wl = queueResponse.waitlistCount
        return Text("\(confirmed)/\(cap) confirmed · \(pending) pending · \(wl) waitlist")
            .font(.caption).foregroundColor(.gray)
    }

    private var swipeOverlayColor: Color {
        guard dragOffset.width != 0 else { return .clear }
        if dragOffset.width > 40 && !isFull {
            return Color.mainColor.opacity(min(Double(dragOffset.width / 150), 0.35))
        } else if dragOffset.width < -40 {
            return Color.red.opacity(min(Double(-dragOffset.width / 150), 0.35))
        }
        return .clear
    }

    private func swipe(accept: Bool, user: PendingRequester) {
        let targetX: CGFloat = accept ? 600 : -600
        withAnimation(.easeOut(duration: 0.25)) {
            dragOffset = CGSize(width: targetX, height: 0)
            cardRotation = accept ? 15 : -15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            dragOffset = .zero
            cardRotation = 0
            onRespond(user.userId, accept)
        }
    }
}
