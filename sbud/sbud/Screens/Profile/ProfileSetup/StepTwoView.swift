//
//  StepTwoView.swift
//  sbud
//
//  Created by Erdal on 23.03.2026.
//

import SwiftUI
// StepTwoView.swift
// Details step: phone, gender, birth date, preferred activity.
//
// Key design change: showGenderPicker and showCalendar are now
// @State inside this view. The parent never needs to know about them,
// so they don't belong in the parent (ISP / encapsulation).

import SwiftUI

struct StepTwoView: View {

    @EnvironmentObject private var vm: ProfileSetupVM

    // Overlay state lives here, closest to where it is used.
    @State private var showGenderPicker = false
    @State private var showCalendar = false
    @State private var calendarSelection = Date()

    private let cardBG = Color(white: 0.12)
    private let genders = ["Male", "Female"]

    private var isOverlayOpen: Bool { showGenderPicker || showCalendar }

    var body: some View {
        ZStack {
            mainContent
                .blur(radius: isOverlayOpen ? 6 : 0)
                .allowsHitTesting(!isOverlayOpen)
                .animation(.easeInOut(duration: 0.25), value: isOverlayOpen)

            if showGenderPicker { genderPickerOverlay }
            if showCalendar     { calendarOverlay }
        }
    }

    // MARK: - Main scroll content

    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                phoneSection
                HStack(alignment: .top, spacing: 12) {
                    genderButton
                    dateButton
                }
                activitySection

                if let error = vm.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(Color("palelime"))
                }
            }
            .padding(.bottom, 80)
        }
    }

    // MARK: - Header

    private var header: some View {
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
            fieldLabel("PHONE NUMBER")
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

    // MARK: - Gender

    private var genderButton: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("GENDER")
            Button { withAnimation(.spring()) { showGenderPicker = true } } label: {
                HStack {
                    Text(vm.profile.gender?.uppercased() ?? "SELECT")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(
                            vm.profile.gender == nil
                            ? Color("turquoise").opacity(0.4)
                            : Color("turquoise")
                        )
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
        .onChange(of: vm.profile.gender) { _ in vm.clearError() }
    }

    // MARK: - Birth date

    private var dateButton: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("BIRTH DATE")
            Button { withAnimation(.spring()) { showCalendar = true } } label: {
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
        .onChange(of: vm.profile.birthDate) { _ in vm.clearError() }
    }

    // MARK: - Activity grid

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            fieldLabel("PREFERRED ACTIVITY")

            let activities: [(icon: String, title: String, sport: ActivityType)] = [
                ("figure.run",              "RUNNING",  .running),
                ("figure.outdoor.cycle",    "CYCLING",  .cycling),
                ("dumbbell.fill",           "GYM",      .gym),
                ("figure.skiing.downhill",  "SKIING",   .skiing),
                ("figure.pool.swim",        "SWIMMING", .swimming),
                ("figure.hiking",           "HIKING",   .hiking),
                ("figure.yoga",             "YOGA",     .yoga),
                ("figure.tennis",           "TENNIS",   .tennis),
            ]

            // Pair them into rows of 2
            let rows = stride(from: 0, to: activities.count, by: 2).map {
                Array(activities[$0 ..< min($0 + 2, activities.count)])
            }

            ForEach(rows, id: \.first?.title) { row in
                HStack(alignment: .top, spacing: 12) {
                    ForEach(row, id: \.title) { item in
                        ActivityRow(
                            icon: item.icon,
                            title: item.title,
                            isSelected: vm.profile.preferredActivity == item.sport
                        ) {
                            vm.profile.preferredActivity = item.sport
                        }
                    }
                }
            }
        }
    }

    // MARK: - Overlays

    private var genderPickerOverlay: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { withAnimation(.spring()) { showGenderPicker = false } }

            VStack(spacing: 0) {
                Text("SELECT GENDER")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .kerning(1.2)
                    .padding(.vertical, 14)

                ForEach(genders, id: \.self) { gender in
                    Divider().background(Color.white.opacity(0.08))
                    Button {
                        withAnimation {
                            vm.profile.gender = gender
                            vm.clearError()
                            showGenderPicker = false
                        }
                    } label: {
                        Text(gender.uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 64)
                            .background(Color(white: 0.10))
                    }
                }
            }
            .background(Color(white: 0.08))
            .cornerRadius(4)
            .padding(.horizontal, 12)
            .padding(.bottom, 80)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private var calendarOverlay: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { withAnimation(.spring()) { showCalendar = false } }

            VStack(spacing: 0) {
                CustomCalendarView(selectedDate: $calendarSelection)
                    .frame(maxWidth: .infinity)

                Button {
                    withAnimation(.spring()) {
                        vm.profile.birthDate = calendarSelection
                        vm.clearError()
                        showCalendar = false
                    }
                } label: {
                    Text("CONFIRM")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("palelime"))
                        .cornerRadius(4)
                }
                .padding([.horizontal, .bottom], 15)
                .padding(.top, 8)
            }
            .background(Color(white: 0.08))
            .cornerRadius(4)
            .padding(.horizontal, 12)
            .padding(.bottom, 80)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Helpers

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.gray)
            .kerning(1.2)
    }
}

// MARK: - Activity Row (private, only used here)

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
                        .stroke(isSelected ? Color("turquoise") : .gray, lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    if isSelected {
                        Circle().fill(Color("turquoise")).frame(width: 9, height: 9)
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 54)
            .background(Color.white.opacity(0.05))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        isSelected ? Color("turquoise").opacity(0.3) : .clear,
                        lineWidth: 1
                    )
            )
            .animation(nil, value: isSelected)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}
