//
//  StoryImagePage.swift
//  sbud
//

import SwiftUI
import Kingfisher

struct StoryImagePage: View {
    let imageUrl: String
    let authorName: String?
    let authorImageUrl: String?
    let currentIndex: Int
    let totalImages: Int

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                StoryProgressBar(totalImages: totalImages, currentIndex: currentIndex)
                    .padding(.top, 56)
                authorHeader
                Spacer()
            }
        }
    }

    private var authorHeader: some View {
        HStack(spacing: 10) {
            authorAvatar
            if let name = authorName {
                Text(name)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var authorAvatar: some View {
        if let urlString = authorImageUrl, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.blueColor.opacity(0.4))
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundStyle(Color.blueColor)
                }
        }
    }
}

#Preview {
    StoryImagePage(
        imageUrl: "https://picsum.photos/400/700",
        authorName: "Ahmed Adel",
        authorImageUrl: "https://images.ctfassets.net/h6goo9gw1hh6/2sNZtFAWOdP1lmQ33VwRN3/24e953b920a9cd0ff2e1d587742a2472/1-intro-photo-final.jpg?w=1200&h=992&fl=progressive&q=70&fm=jpg",
        currentIndex: 1,
        totalImages: 3
    )
}
