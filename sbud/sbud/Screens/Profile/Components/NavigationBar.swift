//
//  NavigationBar.swift
//  sbud
//
//  Created by Erdal on 21.04.2026.
//

import SwiftUI

struct navigationBar: View {
    var onClose: (() -> Void)? = nil

    var body: some View {
        HStack {
            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }

            Spacer()

            Text("SBUD")
                .font(.system(size: 16, weight: .black))
                .foregroundColor(Color("palelime"))
                .kerning(2)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.black)
    }
}
