//
//  ViewCreateStory.swift
//  sbud
//

import SwiftUI
import PhotosUI

struct ViewCreateStory: View {
    let onDidPost: () -> Void
    @State private var vm = ViewModelCreateStory()
    @EnvironmentObject private var coordinator: StoriesCoordinator

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.darkBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    StoryMainPreviewView(
                        isLoadingImages: vm.isLoadingImages,
                        selectedImages: vm.selectedImages,
                        previewIndex: vm.previewIndex,
                        selectedItems: $vm.selectedItems
                    )

                    StoryThumbnailStripView(
                        selectedImages: vm.selectedImages,
                        selectedItems: $vm.selectedItems,
                        previewIndex: $vm.previewIndex
                    )
                    .padding(.top, 10)

                    VStack(spacing: 14) {
                        StoryCaptionFieldView(caption: $vm.caption)
                        StoryEventFieldView(
                            selectedEvent: $vm.selectedEvent,
                            availableEvents: vm.availableEvents,
                            isLoadingEvents: vm.isLoadingEvents
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                    Button {
                        Task { await vm.post() }
                    } label: {
                        if vm.isPosting {
                            ProgressView().tint(Color.darkBackground)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.up.circle.fill")
                                Text("Post Story")
                            }
                        }
                    }
                    .buttonStyle(PrimaryButton())
                    .disabled(!vm.canPost)
                    .opacity(vm.canPost ? 1 : 0.4)
                    .padding(.top, 32)
                    .padding(.bottom, 32)
                    .animation(.easeInOut(duration: 0.2), value: vm.canPost)

                    Spacer(minLength: 110)
                }
            }
        }
        .ignoresSafeArea()
        .navigationTitle("New Story")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { onDidPost() }
                    .foregroundStyle(.white.opacity(0.6))
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .foregroundStyle(Color.mainColor)
                }
            }
        }
        .onChange(of: vm.selectedItems) { _, _ in
            Task { await vm.onItemsChanged() }
        }
        .onChange(of: vm.didPost) { _, posted in
            if posted { onDidPost() }
        }
        .task { await vm.loadUserEvents() }
    }
}

#Preview {
    ViewCreateStory(onDidPost: {})
}
