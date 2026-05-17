//
//  ViewMetricsSummarySimple.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import SwiftUI

// MARK: - ViewMetricsSummarySimple
// Used for gym, yoga, tennis — activities that only track elapsed time.
// No map, no fake metrics. Just a focused, immersive timer screen.

struct ViewMetricsSummarySimple: View {
    let collector: (any MetricsCollectorTimeable)
    let activityType: ActivityType  // drives the icon + colour accent

    private var accent: Color {
        switch activityType {
        case .gym:    return .neonCyan
        case .yoga:   return Color(red: 0.75, green: 0.55, blue: 1.0)   // soft purple
        case .tennis: return Color(red: 0.4,  green: 1.0,  blue: 0.55)  // lime green
        default:      return .neonCyan
        }
    }

    private var icon: String {
        switch activityType {
        case .gym:    return "dumbbell.fill"
        case .yoga:   return "figure.mind.and.body"
        case .tennis: return "tennis.racket"
        default:      return "bolt.fill"
        }
    }

    private var tagline: String {
        switch activityType {
        case .gym:    return "STAY IN THE ZONE"
        case .yoga:   return "BREATHE & FLOW"
        case .tennis: return "KEEP YOUR EYE ON THE BALL"
        default:      return "KEEP GOING"
        }
    }

    var body: some View {
        ZStack {
            Color.surfaceBg.ignoresSafeArea()
            GridPatternView().ignoresSafeArea().opacity(0.5)

            // Radial glow centred on icon
            RadialGradient(
                colors: [accent.opacity(0.12), .clear],
                center: .center,
                startRadius: 20,
                endRadius: 280
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {

                Spacer()

                // ── Activity icon ─────────────────────────────────────────
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.1))
                        .frame(width: 90, height: 90)
                        .overlay(
                            Circle()
                                .strokeBorder(accent.opacity(0.35), lineWidth: 1.5)
                        )
                        .shadow(color: accent.opacity(0.3), radius: 20)

                    Image(systemName: icon)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(accent)
                        .shadow(color: accent.opacity(0.6), radius: 8)
                }

                // ── Elapsed timer ─────────────────────────────────────────
                VStack(spacing: 6) {
                    Text("ELAPSED")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(.labelGray)

                    SessionTimerView(collector: collector)
                }

                // ── Tagline ───────────────────────────────────────────────
                Text(tagline)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(2.5)
                    .foregroundColor(accent.opacity(0.7))

                Spacer()
            }
        }
    }
}

// MARK: - Preview

//#Preview {
//    ViewMetricsSummarySimple(
//        startDateTime: Date(),
//        activityType: .yoga
//    )
//    .preferredColorScheme(.dark)
//}
