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
        KFImage(URL(string: coverImgURL))
            .placeholder {
                ProgressView()
            }
            .resizable()
            .scaledToFill()
            .frame(height: 330)
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
