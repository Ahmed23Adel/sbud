//
//  SkeletonView.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import SwiftUI

struct SkeletonView: View {
    @State private var shimmer = false

    var body: some View {
        Rectangle()
            .fill(LinearGradient(
                colors: [Color(white: 0.15), Color(white: 0.22), Color(white: 0.15)],
                startPoint: shimmer ? .topLeading : .bottomTrailing,
                endPoint: shimmer ? .bottomTrailing : .topLeading
            ))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    shimmer = true
                }
            }
    }
}

struct RecommendedSkeletonCard: View {
    private let cardWidth = UIScreen.main.bounds.width - 40
    private let cardHeight: CGFloat = 300

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SkeletonView()
            VStack(alignment: .leading, spacing: 12) {
                SkeletonView().frame(width: 80, height: 22).clipShape(RoundedRectangle(cornerRadius: 4))
                VStack(alignment: .leading, spacing: 6) {
                    SkeletonView().frame(width: cardWidth * 0.7, height: 28).clipShape(RoundedRectangle(cornerRadius: 4))
                    SkeletonView().frame(width: cardWidth * 0.5, height: 28).clipShape(RoundedRectangle(cornerRadius: 4))
                }
                SkeletonView().frame(width: cardWidth * 0.85, height: 14).clipShape(RoundedRectangle(cornerRadius: 4))
                SkeletonView().frame(maxWidth: .infinity, minHeight: 48).clipShape(RoundedRectangle(cornerRadius: 4)).padding(.top, 5)
            }
            .padding(25)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
