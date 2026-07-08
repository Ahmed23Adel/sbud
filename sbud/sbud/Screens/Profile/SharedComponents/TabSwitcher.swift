//
//  TabSwitcher.swift
//  sbud
//
//  Created by Erdal on 17.05.2026.
//

import SwiftUI

struct TabSwitcher<Tab: Hashable>: View {
    let tabs: [(title: String, tab: Tab)]
    @Binding var selected: Tab

    var body: some View {
        GeometryReader { geo in
            let tabWidth = (geo.size.width - CGFloat(tabs.count - 1) * 4) / CGFloat(tabs.count)
            let selectedIndex = tabs.firstIndex(where: { $0.tab == selected }) ?? 0

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("palelime"))
                    .frame(width: tabWidth, height: 40)
                    .offset(x: CGFloat(selectedIndex) * (tabWidth + 4))
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selected)

                HStack(spacing: 4) {
                    ForEach(tabs, id: \.title) { item in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selected = item.tab
                            }
                        } label: {
                            Text(item.title)
                                .font(.system(size: 13, weight: .bold))
                                .kerning(0.5)
                                .foregroundColor(selected == item.tab
                                    ? Color(red: 0.15, green: 0.25, blue: 0.0)
                                    : .gray)
                                .frame(width: tabWidth, height: 40)
                                .animation(.easeInOut(duration: 0.2), value: selected)
                        }
                    }
                }
            }
            .frame(height: 40)
            .padding(2)
            .background(Color(white: 0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(height: 44)
    }
}
