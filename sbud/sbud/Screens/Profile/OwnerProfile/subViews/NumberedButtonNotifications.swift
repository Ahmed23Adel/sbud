//
//  NumberedButtonNotifications.swift
//  sbud
//
//  Created by ahmed on 03/05/2026.
//

import SwiftUI

struct NumberedButtonNotifications: View {
    var onTapGestureFunc: () -> Void
    var buttonIcon: String
    @Binding var pendingRequestCount: Int
    var body: some View {
        Button {
            onTapGestureFunc()
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: buttonIcon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                if pendingRequestCount > 0 {
                    Text("\(pendingRequestCount)")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.black)
                        .padding(3)
                        .background(Color("palelime"))
                        .clipShape(Circle())
                        .offset(x: 6, y: -6)
                }
            }
        }
    }
}
//
//#Preview {
//    NumberedButtonNotifications()
//}
