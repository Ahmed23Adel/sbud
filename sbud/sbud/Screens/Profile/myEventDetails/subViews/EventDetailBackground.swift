//
//  EventDetailBackground.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI

struct EventDetailBackground: View {
    let coverImgURL: String?

    var body: some View {
        VStack {
            if let coverImg = coverImgURL {
                FadingEventImage(coverImgURL: coverImg)
                    .ignoresSafeArea()
            } else {
                LoadingView()
                    .ignoresSafeArea()
            }
            Spacer()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    EventDetailBackground(coverImgURL: "")
}
