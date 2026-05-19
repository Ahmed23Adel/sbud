//
//  QRCodeViewUI.swift
//  sbud
//
//  Created by ahmed on 05/05/2026.
//

import SwiftUI
import QRCode

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
