//
//  MainAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//

import SwiftUI

struct MainAppCoordinator: View {
    @StateObject private var coordinator = MainCoordinator()
    var body: some View {
        Group{
            switch coordinator.currentRoute{ //START: switch
            case .homePage:
                HomeTabsView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)))
            case .signUp:
                SignUpView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)))
            case .signIn:
                SignInView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)))
            } //END: switch
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentRoute)
        .environmentObject(coordinator)
    }
}

#Preview {
    MainAppCoordinator()
}
