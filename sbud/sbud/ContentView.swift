//
//  ContentView.swift
//  sbud
//
//  Created by ahmed on 05/12/2025.
//

import SwiftUI

struct ContentView: View {
    let authManager = AuthenticationManager.shared
    @EnvironmentObject var coordinator: MainCoordinator
    init() {
    }
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("ContentView")
            Button {
                Task {
                    try await authManager.signOut()
                    coordinator.goToSignUp()
                }
            } label: {
                Text("sign out")
            }
        }
        .padding()
    }
}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environmentObject(MainCoordinator())
//    }
//}
