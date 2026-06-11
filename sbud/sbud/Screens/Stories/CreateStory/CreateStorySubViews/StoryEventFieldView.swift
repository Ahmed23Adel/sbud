//
//  StoryEventFieldView.swift
//  sbud
//

import SwiftUI
import Kingfisher

struct StoryEventFieldView: View {
    @Binding var selectedEvent: ViewModelCreateStory.EventSummary?
    let availableEvents: [ViewModelCreateStory.EventSummary]
    let isLoadingEvents: Bool
    @EnvironmentObject private var coordinator: StoriesCoordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Event", systemImage: "link")
                .font(.subheadline.bold())
                .foregroundStyle(.white)

            Button {
                coordinator.showEventPicker(
                    events: availableEvents,
                    isLoading: isLoadingEvents,
                    selectedId: selectedEvent?.id,
                    onSelect: { selectedEvent = $0 }
                )
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedEvent != nil
                                  ? Color.mainColor.opacity(0.15)
                                  : Color.blueColor.opacity(0.1))
                            .frame(width: 40, height: 40)

                        if let url = selectedEvent.flatMap({ URL(string: $0.imageUrl) }) {
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Image(systemName: selectedEvent?.activityType.icon ?? "figure.run")
                                .font(.subheadline)
                                .foregroundStyle(selectedEvent != nil ? Color.mainColor : Color.blueColor)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedEvent?.title ?? "Select event to link")
                            .font(.subheadline)
                            .foregroundStyle(selectedEvent == nil ? .white.opacity(0.35) : .white)
                            .lineLimit(1)
                        if selectedEvent == nil {
                            Text("Stories must be tied to an event")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.25))
                        }
                    }

                    Spacer()

                    if selectedEvent != nil {
                        Button {
                            selectedEvent = nil
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
                            selectedEvent != nil
                                ? Color.mainColor.opacity(0.5)
                                : Color.white.opacity(0.08),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.2), value: selectedEvent?.id)
        }
    }
}

private let _mockEvents: [ViewModelCreateStory.EventSummary] = [
    .init(id: "1", title: "Morning Run — Parco Sempione", imageUrl: "", activityType: .running),
    .init(id: "2", title: "Sunday Cycling", imageUrl: "", activityType: .cycling)
]

#Preview("No event selected") {
    StoryEventFieldView(
        selectedEvent: .constant(nil),
        availableEvents: _mockEvents,
        isLoadingEvents: false
    )
    .environmentObject(StoriesCoordinator())
    .padding()
    .background(Color.darkBackground)
}

#Preview("Event selected") {
    StoryEventFieldView(
        selectedEvent: .constant(_mockEvents[0]),
        availableEvents: _mockEvents,
        isLoadingEvents: false
    )
    .environmentObject(StoriesCoordinator())
    .padding()
    .background(Color.darkBackground)
}
