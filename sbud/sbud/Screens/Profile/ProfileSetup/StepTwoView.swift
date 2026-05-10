//
//  StepTwoView.swift
//  sbud
//
//  Created by Erdal on 23.03.2026.
//

import SwiftUI

struct StepTwoView: View {
    @EnvironmentObject var vm: ProfileSetupVM

    @Binding var showGenderPicker: Bool
    @Binding var showCalendar: Bool

    let cardBG = Color(white: 0.12)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                phoneSection
                HStack(alignment: .top, spacing: 12) {
                    genderButton
                        .onChange(of: vm.profile.gender) { _ in
                            vm.clearError()
                        }
                    dateButton
                        .onChange(of: vm.profile.birthDate) { _ in
                            vm.clearError()
                        }
                }
                activitySection
                if let err = vm.errorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(Color("palelime"))
                        .padding(.top, -2)
                }
            }
            .padding(.bottom, 80)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("COMPLETE YOUR\nDETAILS")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)
                .lineSpacing(2)

            Text("Configure your details to reach the best experience.")
               .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
    }

    // MARK: - Phone

    private var phoneSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PHONE NUMBER")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .kerning(1.2)

            PhoneNumberView(text: $vm.phoneNumber)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .background(cardBG)
                .frame(height: 54)
                .cornerRadius(4)
                .onChange(of: vm.phoneNumber) { _ in vm.clearError() }
        }
    }
    // MARK: - Gender Button

    private var genderButton: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GENDER")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .kerning(1.2)

            Button {
                withAnimation(.spring()) { showGenderPicker = true }
            } label: {
                HStack {
                    Text(vm.profile.gender?.uppercased() ?? "SELECT")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(vm.profile.gender == nil ? Color("turquoise").opacity(0.4) : Color("turquoise"))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 14)
                .frame(height: 54)
                .background(cardBG)
                .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Date Button

    private var dateButton: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BIRTH DATE")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .kerning(1.2)

            Button {
                withAnimation(.spring()) { showCalendar = true }
            } label: {
                HStack {
                    if let bd = vm.profile.birthDate {
                        Text(bd, format: .dateTime.month(.twoDigits).day(.twoDigits).year())
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color("turquoise"))
                    } else {
                        Text("MM/DD/YYYY")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color("turquoise").opacity(0.4))
                    }
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 14)
                .frame(height: 54)
                .background(cardBG)
                .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Activity

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PREFERRED ACTIVITY")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .kerning(1.2)
            
            HStack(alignment: .top, spacing: 12) {
                ActivityRow(icon: "figure.run", title: "RUNNING",
                            isSelected: vm.profile.preferredActivity == .running
                ) { vm.profile.preferredActivity = .running }
                
                ActivityRow(icon: "figure.outdoor.cycle", title: "CYCLING",
                            isSelected: vm.profile.preferredActivity == .cycling
                ) { vm.profile.preferredActivity = .cycling }
            }
            HStack(alignment: .top, spacing: 12) {
                ActivityRow(icon: "dumbbell.fill", title: "GYM",
                            isSelected: vm.profile.preferredActivity == .gym
                ) { vm.profile.preferredActivity = .gym }
                
                ActivityRow(icon: "figure.skiing.downhill", title: "SKIING",
                            isSelected: vm.profile.preferredActivity == .skiing
                ) { vm.profile.preferredActivity = .skiing }
            }
            HStack(alignment: .top, spacing: 12) {
                ActivityRow(icon: "figure.pool.swim", title: "SWIMMING",
                            isSelected: vm.profile.preferredActivity == .swimming
                ) { vm.profile.preferredActivity = .swimming }
                
                ActivityRow(icon: "figure.hiking", title: "HIKING",
                            isSelected: vm.profile.preferredActivity == .hiking
                ) { vm.profile.preferredActivity = .hiking }
            }
            HStack(alignment: .top, spacing: 12) {
                ActivityRow(icon: "figure.yoga", title: "YOGA",
                            isSelected: vm.profile.preferredActivity == .yoga
                ) { vm.profile.preferredActivity = .yoga }
                
                ActivityRow(icon: "figure.tennis", title: "TENNIS",
                            isSelected: vm.profile.preferredActivity == .tennis
                ) { vm.profile.preferredActivity = .tennis }
            }
        }
    }
}

// MARK: - Activity Row

private struct ActivityRow: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color("turquoise") : .gray)
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? Color("turquoise") : Color.gray, lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    if isSelected {
                        Circle()
                            .fill(Color("turquoise"))
                            .frame(width: 9, height: 9)
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 54)
            .background(Color.white.opacity(0.05))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isSelected ? Color("turquoise").opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .animation(nil, value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
