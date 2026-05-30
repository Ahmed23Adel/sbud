//
//  StoryProgressBar.swift
//  sbud
//

import SwiftUI

struct StoryProgressBar: View {
    let totalImages: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalImages, id: \.self) { i in
                Capsule()
                    .fill(i <= currentIndex ? Color.mainColor : Color.white.opacity(0.4))
                    .frame(height: 3)
            }
        }
        .padding(.horizontal, 12)
        .animation(.easeInOut(duration: 0.2), value: currentIndex)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 20) {
            StoryProgressBar(totalImages: 4, currentIndex: 0)
            StoryProgressBar(totalImages: 4, currentIndex: 2)
            StoryProgressBar(totalImages: 1, currentIndex: 0)
        }
        .padding()
    }
}
