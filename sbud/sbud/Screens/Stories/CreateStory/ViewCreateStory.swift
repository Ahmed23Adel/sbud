//
//  ViewCreateStory.swift
//  sbud
//

import SwiftUI
import PhotosUI

struct ViewCreateStory: View {
    let onDidPost: () -> Void
    @State private var vm = ViewModelCreateStory()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.darkBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        mainPreview
                        thumbnailStrip
                            .padding(.top, 10)
                        formFields
                            .padding(.top, 20)
                        Spacer(minLength: 110)
                    }
                }

                postButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }
            .navigationTitle("New Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { onDidPost() }
                        .foregroundStyle(.white.opacity(0.6))
                }
                ToolbarItem(placement: .keyboard) {
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
            .sheet(isPresented: $vm.showEventPicker) {
                StoryEventPicker(
                    events: vm.availableEvents,
                    isLoading: vm.isLoadingEvents,
                    selectedId: vm.selectedEvent?.id
                ) { event in
                    vm.selectedEvent = event
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

    // MARK: - Main preview

    private var mainPreview: some View {
        ZStack {
            Color.blackBackground

            if vm.isLoadingImages {
                ProgressView().tint(Color.mainColor)
            } else if vm.selectedImages.indices.contains(vm.previewIndex) {
                Image(uiImage: vm.selectedImages[vm.previewIndex])
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                addPhotosPrompt
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.52)
        .clipped()
    }

    private var addPhotosPrompt: some View {
        PhotosPicker(
            selection: $vm.selectedItems,
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

    // MARK: - Thumbnail strip

    @ViewBuilder
    private var thumbnailStrip: some View {
        if !vm.selectedImages.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    PhotosPicker(
                        selection: $vm.selectedItems,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        addThumbnailCell
                    }

                    ForEach(vm.selectedImages.indices, id: \.self) { i in
                        thumbnailCell(index: i)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 72)
        }
    }

    private var addThumbnailCell: some View {
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
                            style: StrokeStyle(lineWidth: 1.5, dash: [4])
                        )
                )
            Image(systemName: "plus")
                .font(.title3.bold())
                .foregroundStyle(Color.mainColor)
        }
        .frame(width: 60, height: 60)
    }

    private func thumbnailCell(index: Int) -> some View {
        let isSelected = index == vm.previewIndex
        return Image(uiImage: vm.selectedImages[index])
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
            .animation(.spring(response: 0.25), value: vm.previewIndex)
            .onTapGesture { vm.previewIndex = index }
    }

    // MARK: - Caption + event

    private var formFields: some View {
        VStack(spacing: 14) {
            captionField
            eventField
        }
        .padding(.horizontal, 16)
    }

    private var captionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Caption", systemImage: "text.alignleft")
                .font(.subheadline.bold())
                .foregroundStyle(.white)

            ZStack(alignment: .topLeading) {
                if vm.caption.isEmpty {
                    Text("What happened?")
                        .foregroundStyle(.white.opacity(0.3))
                        .font(.subheadline)
                        .padding(.top, 1)
                        .padding(.leading, 4)
                }
                TextEditor(text: $vm.caption)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.white)
                    .tint(Color.mainColor)
                    .font(.subheadline)
                    .frame(minHeight: 70)
                    .onChange(of: vm.caption) { _, new in
                        if new.count > 500 { vm.caption = String(new.prefix(500)) }
                    }
            }
            .padding(14)
            .background(Color.blackBackground, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )

            HStack {
                Spacer()
                Text("\(vm.caption.count)/500")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
    }

    private var eventField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Event", systemImage: "link")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text("Required")
                    .font(.caption2.bold())
                    .foregroundStyle(Color.mainColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.mainColor.opacity(0.15), in: Capsule())
            }

            Button { vm.showEventPicker = true } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(vm.selectedEvent != nil
                                  ? Color.mainColor.opacity(0.15)
                                  : Color.blueColor.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: vm.selectedEvent?.activityType.icon ?? "figure.run")
                            .font(.subheadline)
                            .foregroundStyle(vm.selectedEvent != nil ? Color.mainColor : Color.blueColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(vm.selectedEvent?.title ?? "Select event to link")
                            .font(.subheadline)
                            .foregroundStyle(vm.selectedEvent == nil ? .white.opacity(0.35) : .white)
                            .lineLimit(1)
                        if vm.selectedEvent == nil {
                            Text("Stories must be tied to an event")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.25))
                        }
                    }

                    Spacer()

                    if vm.selectedEvent != nil {
                        Button {
                            vm.selectedEvent = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white.opacity(0.35))
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
                .padding(14)
                .background(Color.blackBackground, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            vm.selectedEvent != nil
                                ? Color.mainColor.opacity(0.5)
                                : Color.white.opacity(0.08),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.2), value: vm.selectedEvent?.id)
        }
    }

    // MARK: - Post button

    private var postButton: some View {
        Button {
            Task { await vm.post() }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        vm.canPost
                            ? LinearGradient(
                                colors: [Color.mainColor, Color.mainColor.opacity(0.85)],
                                startPoint: .leading, endPoint: .trailing
                              )
                            : LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.white.opacity(0.06)],
                                startPoint: .leading, endPoint: .trailing
                              )
                    )
                    .frame(height: 54)

                if vm.isPosting {
                    ProgressView().tint(Color.darkBackground)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.body.bold())
                        Text("Post Story")
                            .font(.body.bold())
                    }
                    .foregroundStyle(vm.canPost ? Color.darkBackground : Color.white.opacity(0.25))
                }
            }
        }
        .disabled(!vm.canPost)
        .animation(.easeInOut(duration: 0.2), value: vm.canPost)
    }
}

#Preview {
    ViewCreateStory(onDidPost: {})
}
