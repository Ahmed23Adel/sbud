//
//  ProfileStatsRow.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct ProfileStatsRow: View {
    let friendsCount: Int
    let onFriendsTap: () -> Void
 
    var body: some View {
        HStack(spacing: 0) {
            Button(action: onFriendsTap) {
                ProfileStatItem(
                    value: ProfileUtils.formatCount(friendsCount),
                    label: "FRIENDS"
                )
            }
            Rectangle()
                .fill(Color(white: 0.15))
                .frame(width: 1, height: 28)
        }
        .padding(.vertical, 16)
        .background(Color(white: 0.07))
    }
}
//
//#Preview {
//    ProfileStatsRow()
//}
