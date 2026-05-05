//
//  ShowQRView.swift
//  sbud
//
//  Created by ahmed on 05/05/2026.
//

import SwiftUI
import QRCode

struct ShowQRView: View {
    let userId: String

    var body: some View {
        VStack(spacing: 24) {
            Text("SCAN TO ADD ME")
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(Color("palelime"))
                .tracking(3)

            QRCodeViewUI(userId: userId)
                .frame(width: 240, height: 240)
                .padding(20)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color("palelime").opacity(0.3), radius: 20, x: 0, y: 10)

            Text(userId)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.horizontal, 40)
        }
        .padding(.top, 8)
    }
}

// MARK: - QRCode library wrapper
