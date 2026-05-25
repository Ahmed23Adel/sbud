//
//  EditProfileView.swift
//  sbud
//
//  Created by Erdal on 2.05.2026.
//

import SwiftUI
import Kingfisher
import PhotosUI

struct EditProfileView: View {
    @StateObject private var vm: EditProfileVM
    @Environment(\.dismiss) private var dismiss

    let onSave: (UserProfile) -> Void

    init(profile: UserProfile?, onSave: @escaping (UserProfile) -> Void) {
        _vm = StateObject(wrappedValue: EditProfileVM(profile: profile))
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        avatarSection
                        fieldsSection
                        Spacer(minLength: vm.hasChanges ? 160 : 80)
                    }
                    .padding(.top, 28)
                    .padding(.horizontal, 24)
                }

                if vm.hasChanges {
                    saveBar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .onTapGesture { hideKeyboard() }

            if vm.isSaving {
                LoadingView()
                    .zIndex(10)
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: vm.hasChanges)
        .photosPicker(isPresented: $vm.showPhotoPicker,
                      selection: $vm.selectedPhotoItem,
                      matching: .images)
        .onChange(of: vm.selectedPhotoItem) { _ in
            Task { await vm.loadSelectedPhoto() }
        }
        .overlay {
            if vm.showCalendar {
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) { vm.showCalendar = false }
                        }

                    VStack(spacing: 0) {
                        CustomCalendarView(selectedDate: $vm.tempBirthDate)
                            .frame(maxWidth: .infinity)

                        Button {
                            withAnimation(.spring()) {
                                vm.birthDate = vm.tempBirthDate
                                vm.showCalendar = false
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
                    .background(Color(red: 0.07, green: 0.07, blue: 0.07))
                    .cornerRadius(16)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea()
                .zIndex(20)
                .animation(.spring(), value: vm.showCalendar)
            }
        }
        .alert("Error", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

private extension EditProfileView {

    var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Text("CANCEL")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("EDIT PROFILE")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(.white)
            Spacer()
            Text("CANCEL")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05))
        .overlay(Rectangle().fill(Color(white: 0.12)).frame(height: 1), alignment: .bottom)
    }
}

private extension EditProfileView {

    var avatarSection: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .stroke(Color("turquoise").opacity(0.5), lineWidth: 2)
                        .frame(width: 110, height: 110)
                        .shadow(color: Color("turquoise").opacity(0.3), radius: 10)

                    Group {
                        if let img = vm.selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                        } else if let urlStr = vm.original?.profileImageUrl,
                                  let url = URL(string: urlStr) {
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(28)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                }

                Button { vm.showPhotoPicker = true } label: {
                    ZStack {
                        Circle()
                            .fill(Color("palelime"))
                            .frame(width: 32, height: 32)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                .offset(x: 4, y: 4)
            }

            Text("TAP CAMERA TO CHANGE PHOTO")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .kerning(1)
        }
    }
}

private extension EditProfileView {

    var fieldsSection: some View {
        VStack(spacing: 20) {

            editField(
                label: "FIRST NAME",
                icon: "person",
                placeholder: "Your first name",
                text: $vm.name,
                errorMessage: vm.nameError
            )

            editField(
                label: "LAST NAME",
                icon: "person",
                placeholder: "Your last name",
                text: $vm.surName,
                errorMessage: vm.surNameError
            )

            birthDateField
            preferredActivityField
            bioField
        }
    }

    func editField(
        label: String,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        errorMessage: String?,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        let hasError = errorMessage != nil
        return VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .kerning(1.2)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(hasError ? Color.red.opacity(0.8) : Color("turquoise").opacity(0.7))
                    .frame(width: 22)

                TextField(placeholder, text: text)
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 14)
            .frame(height: 54)
            .background(Color(white: 0.11))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        hasError ? Color.red.opacity(0.6) : Color("turquoise").opacity(0.18),
                        lineWidth: hasError ? 1.5 : 1
                    )
            )

            if let err = errorMessage {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle.fill").font(.system(size: 10))
                    Text(err).font(.system(size: 10, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(.red.opacity(0.85))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }

    var birthDateField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("BIRTH DATE")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .kerning(1.2)

            Button {
                withAnimation(.spring()) { vm.showCalendar = true }
            } label: {
                HStack {
                    Text(vm.birthDate, format: .dateTime.month(.twoDigits).day(.twoDigits).year())
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color("turquoise"))
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 14)
                .frame(height: 54)
                .background(Color(white: 0.12))
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color("turquoise").opacity(0.18), lineWidth: 1)
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    var preferredActivityField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PREFERRED ACTIVITY")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .kerning(1.2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ActivityType.allCases, id: \.self) { activity in
                        let isSelected = vm.preferredActivity == activity
                        Button {
                            vm.preferredActivity = activity
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: activity.icon)
                                    .font(.system(size: 13, weight: .semibold))
                                Text(activity.rawValue)
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(isSelected ? .black : Color("turquoise").opacity(0.8))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                isSelected
                                    ? Color("palelime")
                                    : Color(white: 0.11)
                            )
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(
                                        isSelected
                                            ? Color.clear
                                            : Color("turquoise").opacity(0.18),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    var bioField: some View {
        let hasError = vm.bioError != nil
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("BIO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                    .kerning(1.2)
                Spacer()
                Text("\(vm.bio.count)/120")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(vm.bio.count > 110 ? Color("palelime") : .gray)
            }

            TextEditor(text: $vm.bio)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: 90, maxHeight: 120)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(white: 0.11))
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            hasError ? Color.red.opacity(0.6) : Color("turquoise").opacity(0.18),
                            lineWidth: hasError ? 1.5 : 1
                        )
                )
                .onChange(of: vm.bio) { newVal in
                    if newVal.count > 120 { vm.bio = String(newVal.prefix(120)) }
                }

            if let err = vm.bioError {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle.fill").font(.system(size: 10))
                    Text(err).font(.system(size: 10, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(.red.opacity(0.85))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.bioError)
    }
}

private extension EditProfileView {

    var saveBar: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Text("DISCARD")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(white: 0.12))
                    .cornerRadius(10)
            }

            Button {
                hideKeyboard()
                Task {
                    if let saved = await vm.save() {
                        onSave(saved)
                        dismiss()
                    }
                }
            } label: {
                Text("SAVE CHANGES")
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("palelime"))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05))
        .overlay(Rectangle().fill(Color(white: 0.1)).frame(height: 1), alignment: .top)
    }
}
