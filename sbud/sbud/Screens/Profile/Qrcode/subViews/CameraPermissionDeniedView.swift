//
//  CameraPermissionDeniedView.swift
//  sbud
//
//  Created by ahmed on 05/05/2026.
//

import SwiftUI

struct CameraPermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Camera access is needed to scan QR codes.\nPlease enable it in Settings.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(Color("palelime"))
        }
        .frame(width: 260, height: 260)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

#Preview {
    CameraPermissionDeniedView()
}
