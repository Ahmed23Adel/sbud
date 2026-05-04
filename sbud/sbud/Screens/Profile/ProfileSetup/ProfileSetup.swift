
//
//  Profilee.swift
//  sbud
//
//  Created by Erdal on 24.03.2026.
//

import SwiftUI
import FirebaseAuth

@MainActor
struct ProfileSetupView: View {
    @StateObject private var vm = ProfileSetupVM()
    @State private var showLocationPopup = false
    @EnvironmentObject var coordinator: MainCoordinator
    @Namespace private var buttonTransition
    @State private var isEmailVerified: Bool = Auth.auth().currentUser?.isEmailVerified ?? false
    @State private var showGenderPicker = false
    @State private var showCalendar = false
    @State private var birthDate = Date()

    let genders = ["Male", "Female"]

    private var isOverlayOpen: Bool { showGenderPicker || showCalendar }
    
    private var isFinalStep: Bool {
        vm.currentStep == 3
    }
    
    private var shouldShowEmailBanner: Bool {
        return !isEmailVerified && AuthenticationManager.shared.signInMethod == AuthType.email.rawValue
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("lightblack").ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    
                    if !isFinalStep {
                        navigationBar {
                            coordinator.logout()
                        }
                        
                    }
                    if shouldShowEmailBanner {
                       EmailVerificationBanner {
                           
                           withAnimation(.easeOut) {
                               isEmailVerified = true
                           }
                       }
                       .padding(.horizontal, 24)
                       .padding(.top, 10)
                       .transition(.move(edge: .top).combined(with: .opacity))
                   }
                    
                    if !isFinalStep {
                        headerProgressBar
                            .padding(.horizontal, 24)
                        .padding(.top, 20)}
                
                    if vm.currentStep == 3 {
                        StepFourView()
                            .transition(.opacity)
                            .environmentObject(vm)
                            .ignoresSafeArea()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Group {
                            switch vm.currentStep {
                            case 0: StepOneView().transition(.move(edge: .trailing))
                            case 1: StepTwoView(showGenderPicker: $showGenderPicker, showCalendar: $showCalendar)
                                    .transition(.move(edge: .trailing))
                            case 2: StepThreeView().transition(.move(edge: .trailing))
                            default: StepOneView()
                            }
                        }.animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.currentStep)
                        .environmentObject(vm)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
                .blur(radius: isOverlayOpen ? 6 : 0)
                .allowsHitTesting(!isOverlayOpen)
                .animation(.easeInOut(duration: 0.25), value: isOverlayOpen)
                .animation(.easeInOut, value: Auth.auth().currentUser?.isEmailVerified)

                if showGenderPicker {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) { showGenderPicker = false }
                        }

                    VStack {
                        Spacer()
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
                                        showGenderPicker = false
                                        vm.clearError()
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
                        .cornerRadius(4)//BURAYI DEĞİŞTİRDİM.
                        .padding(.horizontal, 12)
                        .padding(.bottom, 80)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }

                if showCalendar {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) { showCalendar = false }
                        }

                    VStack {
                        Spacer()
                        VStack(spacing: 0) {
                            CustomCalendarView(selectedDate: $birthDate)
                                .frame(maxWidth: .infinity)

                            Button {
                                withAnimation(.spring()) {
                                    vm.profile.birthDate = birthDate
                                    showCalendar = false
                                    vm.clearError()
                                }
                            } label: {
                                Text("CONFIRM")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color("palelime"))
                                    .cornerRadius(4)//BURAYI
                            }
                            .padding([.horizontal, .bottom], 15)
                            .padding(.top, 8)
                        }
                        .background(Color(white: 0.08))
                        .cornerRadius(4)//BURAYII
                        .padding(.horizontal, 12)
                        .padding(.bottom, 80)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isFinalStep {
                bottomBar
                    .blur(radius: isOverlayOpen ? 6 : 0)
                    .allowsHitTesting(!isOverlayOpen)
                    .animation(.easeInOut(duration: 0.25), value: isOverlayOpen)
            }
        }
        .onAppear {
            isEmailVerified = Auth.auth().currentUser?.isEmailVerified ?? false
        }
    }

    // MARK: - Bottom Bar

    @ViewBuilder
    private var bottomBar: some View {
        if vm.currentStep == 0 {
            
            Button(action: { withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { handleContinue() } }) {
                Text("CONTINUE")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.0))

                    .frame(maxWidth: .infinity)
                    .frame(height: 68)
                    .background(
                        Capsule()
                            .fill(Color("palelime"))
                            .matchedGeometryEffect(id: "buttonBG", in: buttonTransition)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .transition(.opacity)
        } else {
            HStack {
                Button(action: { withAnimation(.spring()) { vm.goBack() } }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                }

                Spacer()

                Text("STEP \(String(format: "%02d", vm.currentStep + 1)) / \(vm.currentStep == 3 ? "FINAL" : "04")")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                Button(action: { withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { handleContinue() } }) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color("palelime"))
                                .matchedGeometryEffect(id: "buttonBG", in: buttonTransition)
                        )
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 80)
            .background(Capsule().fill(.black))
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .transition(.opacity)
        }
    }

    // MARK: - Header Progress Bar

    private var headerProgressBar: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 8) {
                ForEach(0..<4) { index in
                    Rectangle()
                        .fill(index <= vm.currentStep ? Color("palelime") : Color.white.opacity(0.1))
                        .frame(height: 4)
                        .animation(.spring(), value: vm.currentStep)
                }
            }

            Text("STEP \(String(format: "%02d", vm.currentStep + 1)) / \(vm.currentStep == 3 ? "FINAL" : "04")")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(Color("turquoise"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.05))
        }
    }

    // MARK: - Helpers
    
    private func handleContinue() {
        withAnimation(.spring()) {
            switch vm.currentStep {
            case 0: if vm.validateStepOne() { vm.goNext() }
            case 1: if vm.validateStepTwo() { vm.goNext() }
            case 2: if vm.validateStepThree() { vm.goNext() }
            case 3:
                break
            default: break
            }
        }
    }

    /*private func handleContinue() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            switch vm.currentStep {
            case 0: if vm.validateStepOne() { vm.goNext() }
            case 1: if vm.validateStepTwo() { vm.goNext() }
            case 2: if vm.validateStepThree() { showLocationPopup = true }
            default: break
            }
        }
    }*/

    private func goBack() {
        switch vm.currentStep {
        case 1: vm.currentStep = 0
        case 2: vm.currentStep = 1
        case 3: vm.currentStep = 2
        default: break
        }
    }
}
