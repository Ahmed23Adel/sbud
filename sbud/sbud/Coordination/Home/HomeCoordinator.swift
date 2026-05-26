//
//  HomeCoordinator.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import SwiftUI
import Combine

@MainActor
final class HomeCoordinator: ObservableObject {

   @Published var navigationPath = NavigationPath()
   @Published var activeSheet: HomeSheet?

   weak var authDelegate: AuthCoordinatorDelegate?

   func pop() {
       guard !navigationPath.isEmpty else { return }
       navigationPath.removeLast()
   }

   func popToRoot() {
       navigationPath = NavigationPath()
   }

   func dismissSheet() {
       activeSheet = nil
   }
}
