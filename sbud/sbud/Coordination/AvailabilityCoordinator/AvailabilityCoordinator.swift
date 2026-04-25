//
//  AvailabilityAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import Foundation
import Combine
import SwiftUI


class AvailabilityCoordinator: ObservableObject {
    @Published var activeSheet: AvailabilitySheetType?
    @Published var navigationPath = NavigationPath()

    func showSheet(_ sheet: AvailabilitySheetType) {
        activeSheet = sheet
    }

    func dismissSheet() {
        activeSheet = nil
    }

    func push(_ destination: AvailabilityNavigationDestination) {
        navigationPath.append(destination)
    }

    func pop() {
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }

    func showPreview(_ event: AvailabilityEvent) {
        if let userId = event.creatorUserId {
            ProfileManager.shared.prefetchProfile(userId: userId)
        }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            activeSheet = .eventPreview(event)
        }
    }

    func dismissPreview() {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            activeSheet = nil}
    }
}
