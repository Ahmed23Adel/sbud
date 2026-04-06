
//
//  Profilee.swift
//  sbud
//
//  Created by Erdal on 24.03.2026.
//

import SwiftUI

struct ProfileSetupView: View {
    @StateObject private var vm = ProfileSetupVM()
    @State private var showLocationPopup = false
    @EnvironmentObject var coordinator: MainCoordinator

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    Group {
                        switch vm.currentStep {
                        case 0:
                            StepOneView()
                        case 1:
                            StepTwoView()
                        case 2:
                            StepThreeView()
                        default:
                            StepOneView()
                        }
                    }

                    Spacer()
                }
                .environmentObject(vm)
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.white)
                .navigationBarTitleDisplayMode(.inline)

                if showLocationPopup {
                    ZStack {
                        Color.black.opacity(0.25)
                            .ignoresSafeArea()
                        
                        LocationPopup(showLocationPopup: $showLocationPopup)
                        .environmentObject(vm)
                        .environmentObject(coordinator)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .zIndex(10)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !showLocationPopup {
                VStack(spacing: 10) {
                    if vm.currentStep > 0 {
                        Button {
                            goBack()
                        } label: {
                            Text("Back")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color("textFieldColor"))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 24)
                    }

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            print("currentStep before:", vm.currentStep)
                                handleContinue()
                                print("currentStep after:", vm.currentStep)
                        }
                    } label: {
                        Text("Continue")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 68)
                            .background(Color.black)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                }
                .background(Color.white)
            }
        }
    }

    private func handleContinue() {
        switch vm.currentStep {
        case 0:
            if vm.validateStepOne() {
                vm.goNext()
            }
        case 1:
            if vm.validateStepTwo() {
                vm.goNext()
            }
        case 2:
            if vm.validateStepThree() {
                showLocationPopup = true
            }
        default:
            break
        }
    }

    private func goBack() {
        switch vm.currentStep {
        case 1:
            vm.currentStep = 0
        case 2:
            vm.currentStep = 1
        case 3:
            vm.currentStep = 2
        default:
            break
        }
    }
}
