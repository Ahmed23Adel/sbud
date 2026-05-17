//
//  ProfileSetupCoordinator.swift
//  sbud
//
//  Created by ahmed on 14/05/2026.
//

import Foundation
import SwiftUI
import Combine
// MARK: - Step Definition

enum ProfileSetupStep: Int, CaseIterable {
    case identity   = 0  // name + photo
    case details    = 1  // phone, gender, birth date, activity
    case bio        = 2  // athletic bio
    case location   = 3  // geo-verification (final)

    var isLast: Bool { self == .location }

    var displayNumber: String { String(format: "%02d", rawValue + 1) }
    var totalDisplay: String { isLast ? "FINAL" : "04" }
}

// MARK: - Coordinator

@MainActor
final class ProfileSetupCoordinator: ObservableObject {

    @Published private(set) var currentStep: ProfileSetupStep = .identity

    // Called by the "Continue / →" button in the bottom bar.
    // The view passes in the validation closure so the coordinator
    // stays free of any form-logic.
    func advance(validating validate: () -> Bool) {
        guard validate() else { return }
        guard let next = ProfileSetupStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = next
        }
    }

    func goBack() {
        guard let previous = ProfileSetupStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.spring()) {
            currentStep = previous
        }
    }

    var isFinalStep: Bool { currentStep.isLast }
    var isFirstStep: Bool { currentStep == .identity }
}
