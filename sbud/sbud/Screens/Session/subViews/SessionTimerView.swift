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
        Text(timeString)
            .font(.system(size: 52, weight: .thin, design: .monospaced))
            .foregroundColor(.white)
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
        seconds = Int(Date().timeIntervalSince(startDate))
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            seconds += 1
        }
    }
}

#Preview {
    SessionTimerView(startDate: Date())
}
