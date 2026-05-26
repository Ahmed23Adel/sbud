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
    @StateObject private var vm = SettingsVM()

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 0) {

                Divider().background(Color(white: 0.12))

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // MARK: - PRIVACY
                        sectionHeader("PRIVACY")

                        privacyRow(
                            icon: "eye.slash.fill",
                            title: "Private Profile",
                            isOn: $vm.isPrivate
                        )

                        Divider().background(Color(white: 0.08)).padding(.leading, 62)

                        sectionHeader("VISIBLE ON PROFILE")

                        privacyRow(
                            icon: "envelope.fill",
                            title: "Show Email",
                            isOn: $vm.showEmail
                        )
                        Divider().background(Color(white: 0.08)).padding(.leading, 62)

                        privacyRow(
                            icon: "phone.fill",
                            title: "Show Phone",
                            isOn: $vm.showPhone
                        )
                        Divider().background(Color(white: 0.08)).padding(.leading, 62)


                        // MARK: - LOGOUT
                        Button {
                            coordinator.coordinatorDidRequestLogout()
                        } label: {
                            HStack(spacing: 14) {
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
                    }
                    .padding(.top, 8)
                }

                if vm.isSaving {
                    HStack(spacing: 8) {
                        ProgressView().tint(Color("palelime")).scaleEffect(0.8)
                        Text("Saving...")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .navigationTitle("SETTINGS")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.05, green: 0.05, blue: 0.05), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { vm.loadFromLocal() }
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .kerning(2)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private func privacyRow(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                Text(isOn.wrappedValue ? "Visible to friends" : "Hidden from everyone")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color("palelime"))
                .onChange(of: isOn.wrappedValue) { _, _ in
                    Task { await vm.savePrivacySettings() }
                }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

#Preview {
    SettingsView()
}
