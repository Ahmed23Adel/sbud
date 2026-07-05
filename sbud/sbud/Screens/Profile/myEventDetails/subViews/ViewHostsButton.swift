//
//  ViewHostsButton.swift
//  sbud
//
//  Created by Erdal on 5.07.2026.
//

import SwiftUI

struct ViewHostsButton: View {
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button(action: onTap) {
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text("View Hosts")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.backgroundColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
            }
        }
        .padding(.horizontal)
    }
}
