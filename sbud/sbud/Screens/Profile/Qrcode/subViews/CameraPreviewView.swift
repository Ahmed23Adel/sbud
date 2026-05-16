//
//  CameraPreviewView.swift
//  sbud
//
//  Created by ahmed on 05/05/2026.
//

import SwiftUI
import AVFoundation
import Vision

struct CameraPreviewView: UIViewControllerRepresentable {
    let onScanned: (String) -> Void
    let onPermissionDenied: () -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        CameraViewController(onScanned: onScanned, onPermissionDenied: onPermissionDenied)
    }

    func updateUIViewController(_ vc: CameraViewController, context: Context) {}
}

//#Preview {
//    CameraPreviewView()
//}
