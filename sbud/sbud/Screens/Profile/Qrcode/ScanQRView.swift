//
//  ScanQRView.swift
//  sbud
//
//  Created by ahmed on 05/05/2026.
//

import SwiftUI
import AVFoundation

struct ScanQRView: View {
    let onScanned: (String) -> Void
    @State private var permissionDenied = false

    var body: some View {
        VStack(spacing: 20) {
            Text("POINT AT A SBUD QR CODE")
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(Color("palelime"))
                .tracking(3)

            if permissionDenied {
                CameraPermissionDeniedView()
            } else {
                ZStack {
                    CameraPreviewView(onScanned: onScanned,
                                      onPermissionDenied: { permissionDenied = true })
                        .frame(width: 260, height: 260)
                        .cornerRadius(20)
                        .clipped()

                    // Corner brackets overlay
                    ScannerBrackets()
                        .frame(width: 260, height: 260)
                }
            }
        }
        .padding(.top, 8)
    }
}


// MARK: - AVFoundation camera preview

