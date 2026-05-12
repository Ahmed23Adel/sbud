//
//  OptionalTextOptionSelector.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//
import SwiftUI

struct OptionalTextOptionSelector<T: RawRepresentable & Hashable & CaseIterable>: View
where T.RawValue == String {
    let header: String
    @Binding var selected: T?

    // Materialize into [T] once at init — no casting, no runtime surprise
    private let allOptions: [T]

    init(header: String, selected: Binding<T?>) {
        self.header = header
        self._selected = selected
        self.allOptions = Array(T.allCases)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !header.isEmpty {
                Text(header)
                    .font(.caption)
                    .foregroundStyle(Color.mainColor)
                    .padding(.horizontal)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(allOptions, id: \.self) { option in
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
                            .foregroundStyle(
                                option == selected ? Color.white : Color.primary
                            )
                            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                            .animation(.easeIn(duration: 0.25), value: selected)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("option:", option)
                                selected = (selected == option) ? nil : option
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
