//
//  StoryThumbnailStripView.swift
//  sbud
//

import SwiftUI
import PhotosUI

struct StoryThumbnailStripView: View {
    let selectedImages: [UIImage]
    @Binding var selectedItems: [PhotosPickerItem]
    @Binding var previewIndex: Int

    var body: some View {
        if !selectedImages.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        addCell
                    }

                    ForEach(selectedImages.indices, id: \.self) { i in
                        thumbnailCell(index: i)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 72)
        }
    }

    private var addCell: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blackBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.mainColor.opacity(0.8), Color.blueColor.opacity(0.5)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 1.5)
                        )
                )
            Image(systemName: "plus")
                .font(.title3.bold())
                .foregroundStyle(Color.mainColor)
        }
        .frame(width: 60, height: 60)
    }

    private func thumbnailCell(index: Int) -> some View {
        let isSelected = index == previewIndex
        return Image(uiImage: selectedImages[index])
            .resizable()
            .scaledToFill()
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isSelected ? Color.mainColor : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.25), value: previewIndex)
            .onTapGesture { previewIndex = index }
    }
}

#Preview {
    let images = [
        UIImage(systemName: "photo")!,
        UIImage(systemName: "photo.fill")!,
        UIImage(systemName: "camera")!
    ]
    StoryThumbnailStripView(
        selectedImages: images,
        selectedItems: .constant([]),
        previewIndex: .constant(0)
    )
    .padding(.vertical)
    .background(Color.darkBackground)
}
