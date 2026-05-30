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
        Button(action: onTap) {
            HStack(spacing: 14) {
                thumbnail
                VStack(alignment: .leading, spacing: 3) {
                    Text(event.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    HStack(spacing: 4) {
                        Image(systemName: event.activityType.icon)
                            .font(.caption2)
                        Text(event.activityType.rawValue)
                            .font(.caption)
                    }
                    .foregroundStyle(Color.blueColor.opacity(0.8))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.mainColor)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.mainColor.opacity(0.1) : Color.blackBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                isSelected ? Color.mainColor.opacity(0.5) : Color.white.opacity(0.07),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let urlString = event.imageUrl, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blueColor.opacity(0.15))
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: event.activityType.icon)
                        .font(.title3)
                        .foregroundStyle(Color.blueColor)
                }
        }
    }
}

#Preview("Unselected") {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        EventPickerRow(
            event: .init(id: "1", title: "Morning Run Milano", imageUrl: nil, activityType: .running),
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
            event: .init(id: "1", title: "Cycling Tour Lake Como", imageUrl: nil, activityType: .cycling),
            isSelected: true,
            onTap: {}
        )
        .padding()
    }
}
