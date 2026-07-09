//
//  FadingEventImage.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI
import Kingfisher

struct FadingEventImage: View {
    var coverImgURL: String
    var body: some View {
        // The photo lives in an overlay so its scaledToFill size can never
        // leak into layout: with a height-only frame, scaledToFill reports
        // width = 330 × image aspect ratio (e.g. 495pt for a 3:2 photo on a
        // 393pt screen), which widens every ancestor and bleeds the whole
        // screen off both edges. A flexible frame does NOT cap this — it
        // adopts the child's oversized width. Overlay + clipped does.
        Color.clear
            .frame(height: 330)
            .overlay {
                KFImage(URL(string: coverImgURL))
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .cornerRadius(16)
            .mask(
                LinearGradient(
                    colors: [.black, .black, .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        
    }
}

#Preview {
    FadingEventImage(coverImgURL: "https://firebasestorage.googleapis.com/v0/b/sbud-e5bdd.firebasestorage.app/o/uploads%2FWKSidc5m3ff36toyy8X7z9xjJWz2%2F28e3f3f5-5138-48e3-84f9-8d0d611f87ae.jpg?alt=media&token=c410e75f-6877-4e9f-8d3d-f57fa3e259c5")
}
