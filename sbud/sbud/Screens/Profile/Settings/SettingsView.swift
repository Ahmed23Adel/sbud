//
//  SettingsView.swift
//  sbud
//
//  Created by Erdal on 27.04.2026.
//

//
//  Settings.swift
//  sbud
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var coordinator: MainCoordinator

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { coordinator.goBack() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("SETTINGS")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .kerning(1.5)
                    Spacer()
                    Color.clear.frame(width: 28, height: 28)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .padding(.top, UIApplication.safeAreaTop)

                Divider().background(Color(white: 0.12))

                Button {
                    coordinator.logout()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16))
                            .foregroundColor(.red.opacity(0.8))
                            .frame(width: 28)
                        Text("Logout Session")
                            .font(.system(size: 15))
                            .foregroundColor(.red.opacity(0.8))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }

                Spacer()
            }
        }
    }
}
