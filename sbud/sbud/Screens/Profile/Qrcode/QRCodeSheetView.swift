//
//  QRCodeSheetView.swift
//  sbud
//
//  Created by ahmed on 05/05/2026.
//

import SwiftUI
import QRCode
import AVFoundation

struct QRCodeSheetView: View {
    let userId: String
    let onScanned: (String) -> Void

    @State private var selectedTab: QRTab = .show
    @Environment(\.dismiss) private var dismiss

    enum QRTab: String, CaseIterable {
        case show = "My QR"
        case scan = "Scan QR"
    }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.08).ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle bar
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 24)

                // Picker
                Picker("Mode", selection: $selectedTab) {
                    ForEach(QRTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)

                // Content
                switch selectedTab {
                case .show:
                    ShowQRView(userId: userId)
                case .scan:
                    ScanQRView { scannedId in
                        onScanned(scannedId)
                    }
                }

                Spacer()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}
