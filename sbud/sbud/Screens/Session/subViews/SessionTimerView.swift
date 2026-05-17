//
//  SessionTimerView.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//
//
//  SessionTimerView.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//
//
//  SessionTimerView.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import SwiftUI

struct SessionTimerView: View {
    let startDate: Date

    @State private var seconds = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 2) {
            Text("ELAPSED")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(2.5)
                .foregroundColor(.labelGray)

            ZStack {
                // Glow layer
                Text(timeString)
                    .font(.system(size: 52, weight: .black, design: .monospaced))
                    .foregroundColor(.neonCyan.opacity(0.2))
                    .blur(radius: 10)

                Text(timeString)
                    .font(.system(size: 52, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(color: .neonCyan.opacity(0.45), radius: 6)
            }
        }
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate() }
        .onChange(of: startDate) { startTimer() }
    }

    private var timeString: String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    private func startTimer() {
        timer?.invalidate()
        seconds = Int(Date().timeIntervalSince(startDate))
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            seconds += 1
        }
    }
}

#Preview {
    ZStack {
        Color.surfaceBg.ignoresSafeArea()
        SessionTimerView(startDate: Date())
    }
    .preferredColorScheme(.dark)
}
