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
                // MARK: NavBar
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // MARK: Privacy Section
                        sectionHeader("PRIVACY")

                        settingsRow {
                            HStack {
                                Image(systemName: vm.isPrivate ? "lock.fill" : "lock.open.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(vm.isPrivate ? Color("turquoise") : .gray)
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Private Account")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                    Text(vm.isPrivate
                                         ? "Only approved followers can see your profile"
                                         : "Anyone can follow you and see your profile")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.gray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer()

                                if vm.isSaving {
                                    ProgressView()
                                        .tint(Color("palelime"))
                                        .scaleEffect(0.8)
                                } else {
                                    Toggle("", isOn: Binding(
                                        get: { vm.isPrivate },
                                        set: { _ in Task { await vm.togglePrivacy() } }
                                    ))
                                    .labelsHidden()
                                    .tint(Color("turquoise"))
                                }
                            }
                        }

                        Divider().background(Color(white: 0.1)).padding(.leading, 20)

                        // MARK: Account Section
                        sectionHeader("ACCOUNT")

                        settingsRow {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 15))
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
                        } action: {
                            coordinator.logout()
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}



// MARK: - Helpers
private extension SettingsView {

    func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .kerning(1.5)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 6)
    }

    // tap olmayan satır
    func settingsRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(white: 0.07))
    }

    // tap olan satır
    func settingsRow<Content: View>(@ViewBuilder content: () -> Content, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            content()
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color(white: 0.07))
                .contentShape(Rectangle())
        }
    }
}

