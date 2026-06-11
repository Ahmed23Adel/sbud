//
//  EmptyState.swift
//  sbud
//
//  Created by Erdal on 17.05.2026.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    init(icon: String = "calendar.badge.exclamationmark", title: String = "NO EVENTS YET", message: String) {
        self.icon = icon
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.2))
            Text(title)
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .kerning(1.5)
            Text(message)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
