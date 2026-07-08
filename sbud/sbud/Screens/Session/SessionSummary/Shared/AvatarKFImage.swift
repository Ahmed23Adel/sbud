//
//  AvatarKFImage.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI
import Kingfisher

/// Circular profile image backed by Kingfisher.
///
/// Behaviour:
/// - **URL is nil / invalid** → renders `fallback` immediately.
/// - **Loading**             → renders a `ProgressView` centred inside the circle.
/// - **Success**             → renders the remote image, clipped to a circle.
/// - **Error**               → renders `fallback` (same as missing URL).
struct AvatarKFImage<Fallback: View>: View {
    let url: URL?
    let size: CGFloat
    @ViewBuilder let fallback: () -> Fallback

    @State private var failed = false

    var body: some View {
        Group {
            if let url, !failed {
                KFImage(url)
                    .placeholder {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.07))
                            ProgressView()
                                .scaleEffect(size < 32 ? 0.55 : 0.75)
                                .tint(.labelGray)
                        }
                        .frame(width: size, height: size)
                    }
                    .onFailure { _ in failed = true }
                    .cancelOnDisappear(true)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                fallback()
            }
        }
    }
}
