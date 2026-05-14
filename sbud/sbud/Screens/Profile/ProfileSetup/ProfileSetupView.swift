//
//  ProfileSetupView.swift
//  sbud
//
//  Created by ahmed on 14/05/2026.
//

import SwiftUI
// ProfileSetupView.swift
// Root shell: owns the chrome (nav bar, progress bar, bottom bar)
// and routes to the correct step view.
// It knows nothing about what fields exist inside each step.

import SwiftUI
import FirebaseAuth

@MainActor
struct ProfileSetupView: View {

    // MARK: - Environment

    @EnvironmentObject private var appCoordinator: MainCoordinator

    // MARK: - Owned objects

    @StateObject private var coordinator = ProfileSetupCoordinator()
    @StateObject private var vm          = ProfileSetupVM()

    // MARK: - Local state

    @State private var isEmailVerified = Auth.auth().currentUser?.isEmailVerified ?? false
    @Namespace private var buttonTransition

    // MARK: - Derived

    private var shouldShowEmailBanner: Bool {
        !isEmailVerified && AuthenticationManager.shared.signInMethod == AuthType.email.rawValue
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color("lightblack").ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    if !coordinator.isFinalStep {
                        navigationBar { appCoordinator.logout() }

                        if shouldShowEmailBanner {
                            EmailVerificationBanner {
                                withAnimation(.easeOut) { isEmailVerified = true }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 10)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        headerProgressBar
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                    }

                    stepContent
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !coordinator.isFinalStep { bottomBar }
        }
        .onAppear {
            isEmailVerified = Auth.auth().currentUser?.isEmailVerified ?? false
        }
        .environmentObject(coordinator)
        .environmentObject(vm)
    }

    // MARK: - Step routing

    @ViewBuilder
    private var stepContent: some View {
        switch coordinator.currentStep {
        case .identity:
            StepOneView()
                .transition(.move(edge: .trailing))
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        case .details:
            StepTwoView()
                .transition(.move(edge: .trailing))
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        case .bio:
            StepThreeView()
                .transition(.move(edge: .trailing))
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

        case .location:
            StepFourView()
                .transition(.opacity)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Progress bar

    private var headerProgressBar: some View {
        let step = coordinator.currentStep
        return VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 8) {
                ForEach(ProfileSetupStep.allCases, id: \.self) { s in
                    Rectangle()
                        .fill(s.rawValue <= step.rawValue
                              ? Color("palelime")
                              : Color.white.opacity(0.1))
                        .frame(height: 4)
                        .animation(.spring(), value: step)
                }
            }

            Text("STEP \(step.displayNumber) / \(step.totalDisplay)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(Color("turquoise"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.05))
        }
    }

    // MARK: - Bottom bar

    @ViewBuilder
    private var bottomBar: some View {
        if coordinator.isFirstStep {
            continueButton
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .transition(.opacity)
        } else {
            backNextBar
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .transition(.opacity)
        }
    }

    private var continueButton: some View {
        Button {
            coordinator.advance(validating: vm.validateStepOne)
        } label: {
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
    }

    private var backNextBar: some View {
        let step = coordinator.currentStep
        return HStack {
            Button { coordinator.goBack() } label: {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
            }

            Spacer()

            Text("STEP \(step.displayNumber) / \(step.totalDisplay)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            Button {
                coordinator.advance(validating: validatorForCurrentStep())
            } label: {
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
        .frame(height: 80)
        .background(Capsule().fill(.black))
        .padding(.horizontal, 14)
    }

    // Maps the current step to the correct validator.
    private func validatorForCurrentStep() -> () -> Bool {
        switch coordinator.currentStep {
        case .identity: return vm.validateStepOne
        case .details:  return vm.validateStepTwo
        case .bio:      return vm.validateStepThree
        case .location: return { true } // final step has its own save button
        }
    }
}
