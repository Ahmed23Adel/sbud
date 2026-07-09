//
//  ViewMyStories.swift
//  sbud
//

import SwiftUI
import Kingfisher

struct ViewMyStories: View {
    @State private var vm = ViewModelMyStories()

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            if vm.isLoading && vm.stories.isEmpty {
                ProgressView().tint(Color.mainColor)
            } else if vm.stories.isEmpty {
                emptyState
            } else {
                storyList
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                PageSectionTitle(title: "MY STORIES")
            }
        }
        .task { await vm.load() }
    }

    // MARK: - List

    private var storyList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(vm.stories) { story in
                    StoryManagementRow(story: story) { imageIndex in
                        Task { await vm.deleteImage(storyId: story.id, imageIndex: imageIndex) }
                    } onDeleteStory: {
                        Task { await vm.deleteStory(storyId: story.id) }
                    }
                }

                if vm.hasMore {
                    ProgressView()
                        .tint(Color.mainColor)
                        .padding()
                        .task { await vm.loadMore() }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.stack")
                .font(.system(size: 48))
                .foregroundStyle(Color.mainColor.opacity(0.6))
            PageSectionTitle(title: "No Stories Yet.")
            Text("Your friends' stories will appear here")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray).frame(maxWidth: .infinity).padding(.vertical, 30)
        }
    }
}

// MARK: - Row

private struct StoryManagementRow: View {
    let story: Story
    let onDeleteImage: (Int) -> Void
    let onDeleteStory: () -> Void

    @State private var showDeleteStoryConfirm = false

    private static let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: date + delete story button
            HStack {
                Text(Self.dateFmt.string(from: story.createdAt))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                Button(role: .destructive) {
                    showDeleteStoryConfirm = true
                } label: {
                    Label("Delete story", systemImage: "trash")
                        .font(.caption)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.red)
                        .padding(8)
                }
            }

            // Horizontal image strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(story.images, id: \.index) { image in
                        StoryImageTile(imageUrl: image.url) {
                            onDeleteImage(image.index)
                        }
                    }
                }
                .padding(.horizontal, 2)
            }

            // Caption if any
            if let text = story.text, !text.isEmpty {
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(Color.blackBackground.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .confirmationDialog(
            "Delete this story?",
            isPresented: $showDeleteStoryConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete story", role: .destructive) { onDeleteStory() }
        } message: {
            Text("All photos in this story will be permanently deleted.")
        }
    }
}

// MARK: - Image tile with delete overlay

private struct StoryImageTile: View {
    let imageUrl: String
    let onDelete: () -> Void

    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 140)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Button {
                showDeleteConfirm = true
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white, .red)
                    .padding(4)
            }
        }
        .confirmationDialog(
            "Delete this photo?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete photo", role: .destructive) { onDelete() }
        } message: {
            Text("This photo will be permanently removed from the story.")
        }
    }
}

#Preview {
    NavigationStack {
        ViewMyStories()
    }
}
