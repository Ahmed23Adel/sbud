//
//  ImagePickerGrid.swift
//  sbud
//

import SwiftUI
import PhotosUI

struct ImagePickerGrid: View {
    @Binding var selectedItems: [PhotosPickerItem]
    let selectedImages: [UIImage]
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader
            imageGrid
        }
    }

    private var sectionHeader: some View {
        HStack {
            Text("Photos")
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Text("\(selectedImages.count)/10")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var imageGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                addButton
                ForEach(selectedImages.indices, id: \.self) { i in
                    Image(uiImage: selectedImages[i])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private var addButton: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 10,
            matching: .images
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1.5, dash: [6])
                    )
                    .foregroundStyle(Color.mainColor.opacity(0.6))
                    .frame(width: 100, height: 100)
                if isLoading {
                    ProgressView().tint(Color.mainColor)
                } else {
                    VStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(Color.mainColor)
                        Text("Add")
                            .font(.caption)
                            .foregroundStyle(Color.mainColor)
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        ImagePickerGrid(
            selectedItems: .constant([]),
            selectedImages: [],
            isLoading: false
        )
        .padding()
    }
}
