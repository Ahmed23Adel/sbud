//
//  EventPickerRow.swift
//  sbud
//

import SwiftUI
import Kingfisher

struct EventPickerRow: View {
    let event: ViewModelCreateStory.EventSummary
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        MyEventRow(event: event.toUsersEvent())
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.mainColor)
                        .padding(10)
                }
            }
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                        .strokeBorder(Color.mainColor.opacity(0.6), lineWidth: 1.5)
                }
            }
            .onTapGesture(perform: onTap)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview("Unselected") {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        EventPickerRow(
            event: .init(id: "1", title: "Morning Run Milano", imageUrl: "nil", activityType: .running),
            isSelected: false,
            onTap: {}
        )
        .padding()
    }
}

#Preview("Selected") {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        EventPickerRow(
            event: .init(id: "1", title: "Cycling Tour Lake Como", imageUrl: "nil", activityType: .cycling),
            isSelected: true,
            onTap: {}
        )
        .padding()
    }
}
