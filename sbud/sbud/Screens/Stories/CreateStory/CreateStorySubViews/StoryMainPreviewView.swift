//
//  StoryMainPreviewView.swift
//  sbud
//

import SwiftUI
import PhotosUI

struct StoryMainPreviewView: View {
    let isLoadingImages: Bool
    let selectedImages: [UIImage]
    let previewIndex: Int
    @Binding var selectedItems: [PhotosPickerItem]

    var body: some View {
        GeometryReader { geo in
            let topInset = geo.safeAreaInsets.top
            let totalHeight = UIScreen.main.bounds.height * 0.52 + topInset

            ZStack {
                Color.blackBackground

                if isLoadingImages {
                    ProgressView().tint(Color.mainColor)
                } else if selectedImages.indices.contains(previewIndex) {
                    Image(uiImage: selectedImages[previewIndex])
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    addPhotosPrompt
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: totalHeight)
            .clipShape(
                .rect(
                    topLeadingRadius: UIConstants.cornerRadius,
                    bottomLeadingRadius: 24,
                    bottomTrailingRadius: 24,
                    topTrailingRadius: UIConstants.cornerRadius
                )
            )
        }
        .frame(height: UIScreen.main.bounds.height * 0.52)
        .ignoresSafeArea(edges: .top)
    }

// MARK: - Preview

    private var addPhotosPrompt: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 10,
            matching: .images
        ) {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.mainColor.opacity(0.15))
                        .frame(width: 72, height: 72)
                    Image(systemName: "photo.stack")
                        .font(.system(size: 30))
                        .foregroundStyle(Color.mainColor)
                }
                Text("Tap to add photos")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))
                Text("Up to 10 images")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
    }
}

#Preview("With image") {
    StoryMainPreviewView(
        isLoadingImages: false,
        selectedImages: [UIImage(systemName: "photo")!],
        previewIndex: 0,
        selectedItems: .constant([])
    )
    .background(Color.darkBackground)
}

#Preview("Empty — add prompt") {
    StoryMainPreviewView(
        isLoadingImages: false,
        selectedImages: [],
        previewIndex: 0,
        selectedItems: .constant([])
    )
    .background(Color.darkBackground)
}

#Preview("Loading") {
    StoryMainPreviewView(
        isLoadingImages: true,
        selectedImages: [],
        previewIndex: 0,
        selectedItems: .constant([])
    )
    .background(Color.darkBackground)
}
