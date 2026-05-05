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

struct QRCodeViewUI: UIViewRepresentable {
    let userId: String

    func makeUIView(context: Context) -> QRCodeView {
        let view = QRCodeView()
        configure(view)
        return view
    }

    func updateUIView(_ uiView: QRCodeView, context: Context) {
        configure(uiView)
    }

    private func configure(_ view: QRCodeView) {
        guard let doc = try? QRCode.Document(
            utf8String: userId,
            errorCorrection: .high
        ) else { return }

        doc.design.shape.eye   = QRCode.EyeShape.RoundedOuter()
        doc.design.shape.pupil = QRCode.PupilShape.Circle()
        doc.design.shape.onPixels = QRCode.PixelShape.RoundedPath(cornerRadiusFraction: 0.7)

        doc.design.style.onPixels = QRCode.FillStyle.Solid(CGColor(gray: 0.08, alpha: 1))
        doc.design.style.eye      = QRCode.FillStyle.Solid(CGColor(gray: 0.08, alpha: 1))
        doc.design.style.pupil    = QRCode.FillStyle.Solid(
            CGColor(red: 0.75, green: 1.0, blue: 0.0, alpha: 1)
        )

        view.document = doc
    }
}
