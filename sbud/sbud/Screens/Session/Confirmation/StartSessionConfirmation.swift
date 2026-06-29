//
//  StartSessionConfirmation.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI
struct StartSessionConfirmation: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: MainCoordinator
    let eventDetails: EventFullDetails

    @State private var pulsing = false

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            DiagonalStripes().ignoresSafeArea().opacity(0.04)

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 36)

                // Activity icon — adapts to any activity type
                ZStack {
                    Circle()
                        .stroke(Color.accentLime.opacity(0.13), lineWidth: 1)
                        .frame(width: 100)
                        .scaleEffect(pulsing ? 1.18 : 1.0)
                    Circle()
                        .stroke(Color.accentLime, lineWidth: 1.5)
                        .frame(width: 80)
                    Image(systemName: eventDetails.activityType.icon)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(Color.accentLime)
                }
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulsing)
                .padding(.bottom, 20)

                // Headline
                VStack(spacing: 0) {
                    Text("Start")
                        .font(.custom("BarlowCondensed-Black", size: 30))
                        .foregroundColor(.white)
                    Text("Session Now?")
                        .font(.custom("BarlowCondensed-Black", size: 30))
                        .foregroundColor(Color.accentLime)
                }
                .multilineTextAlignment(.center)
                .textCase(.uppercase)
                .padding(.bottom, 36)

                // Buttons
                VStack(spacing: 10) {
                    // YES — lime CTA
                    Button {
                        coordinator.navigateTo(
                            .creatorSession(eventDetails: eventDetails, isSessionCreated: false)
                        )
                    } label: {
                        HStack(spacing: 6) {
                            Text("Let's Go")
                                .font(.custom("BarlowCondensed-Black", size: 22))
                                .tracking(1.2)
                                .textCase(.uppercase)
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.15))
                                    .frame(width: 22, height: 22)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .black))
                            }
                        }
                        .foregroundColor(.darkBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentLime)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // NO — matches your end session button style
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 10) {
                            Text("NOT NOW")
                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                .tracking(2)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.neonPink, Color(red: 1.0, green: 0.38, blue: 0.18)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: .neonPink.opacity(0.45), radius: 14, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 24)
                Spacer()
            }
        }
        .onAppear { pulsing = true }
    }
}

struct DiagonalStripes: View {
    var body: some View {
        Canvas { ctx, size in
            let spacing: CGFloat = 24
            var x: CGFloat = -size.height
            while x < size.width + size.height {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x + spacing * 0.6, y: 0))
                path.addLine(to: CGPoint(x: x + spacing * 0.6 + size.height, y: size.height))
                path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                path.closeSubpath()
                ctx.fill(path, with: .color(.white))
                x += spacing
            }
        }
    }
}

extension Color {
    static let accentLime    = Color(red: 0.78, green: 0.96, blue: 0.26)
}
