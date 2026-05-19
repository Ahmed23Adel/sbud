//
//  MidnightLoadingView.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import SwiftUI

struct MidnightLoadingView: View {
    @State private var rotating = false
    @State private var pulsing  = false
    var text = "Loading..."
    var body: some View {
        ZStack {
            Color.surfaceBg.ignoresSafeArea()
            GridPatternView().ignoresSafeArea().opacity(0.5)

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.neonCyan.opacity(0.12), lineWidth: 2)
                        .frame(width: 60, height: 60)

                    Circle()
                        // quarter of a circle only
                        .trim(from: 0, to: 0.25)
                        .stroke(
                            LinearGradient(
                                colors: [.neonCyan, .neonGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(rotating ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotating)
                }

                Text(text)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(3)
                    .foregroundColor(.labelGray)
                    .opacity(pulsing ? 0.35 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulsing)
            }
        }
        .onAppear { rotating = true; pulsing = true }
    }
}


#Preview {
    MidnightLoadingView()
}
