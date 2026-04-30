//
//  TextOptionSelector.swift
//  sbud
//
//  Created by ahmed on 26/04/2026.
//

import SwiftUI


struct TextOptionSelector<T: RawRepresentable & Hashable & CaseIterable>: View
where T.RawValue == String {
    let header: String
    @Binding var selected: T

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.caption)
                .foregroundStyle(Color.mainColor)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(T.allCases) as! [T], id: \.self) { option in
                        Text(option.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(minWidth: 80, minHeight: 44)
                            .background(
                                option == selected
                                    ? Color.mainColor
                                    : Color.backgroundColor
                            )
                            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                            .animation(.easeIn(duration: 0.25), value: selected)
                            .onTapGesture {
                                selected = option
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
#Preview {
    PreviewWrapper()
}

struct PreviewWrapper: View {
    @State private var selected: GymDayType = .push

    var body: some View {
        TextOptionSelector(
            header: "Workout Type",
            selected: $selected
        )
        .padding()
        .background(Color.black) // optional, just to see contrast
    }
}
