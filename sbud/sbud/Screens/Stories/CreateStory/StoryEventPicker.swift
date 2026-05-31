//
//  StoryEventPicker.swift
//  sbud
//

import SwiftUI

struct StoryEventPicker: View {
    let events: [ViewModelCreateStory.EventSummary]
    let isLoading: Bool
    let selectedId: String?
    let onSelect: (ViewModelCreateStory.EventSummary?) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBackground.ignoresSafeArea()
                if isLoading {
                    ProgressView().tint(Color.mainColor)
                } else if events.isEmpty {
                    emptyState
                } else {
                    eventList
                }
            }
            .navigationTitle("Link an Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
    }

    private var eventList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(events) { event in
                    EventPickerRow(event: event, isSelected: event.id == selectedId) {
                        onSelect(event)
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.3))
            Text("No events found")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.6))
            Text("Events you created, hosted, or joined will appear here")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview("With events") {
    let events: [ViewModelCreateStory.EventSummary] = [
        .init(id: "1", title: "Morning Run Milano", imageUrl: "nil", activityType: .running),
        .init(id: "2", title: "Cycling Tour Lake Como", imageUrl: "nil", activityType: .cycling),
        .init(id: "3", title: "Gym Session", imageUrl: "nil", activityType: .gym),
    ]
    StoryEventPicker(events: events, isLoading: false, selectedId: "1") { _ in }
}

#Preview("Loading") {
    StoryEventPicker(events: [], isLoading: true, selectedId: nil) { _ in }
}

#Preview("Empty") {
    StoryEventPicker(events: [], isLoading: false, selectedId: nil) { _ in }
}
