//
//  ownerSession.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI

struct ViewOwnerSession: View {
    @State private var viewModel: ViewModelOwnerSession
    @EnvironmentObject private var mainCoordinator: MainCoordinator
    init(eventId: String, isSessionCreated: Bool) {
        _viewModel = State(initialValue: ViewModelOwnerSession(eventId: eventId, isSessionCreated: isSessionCreated))
    }

    var body: some View {
        ZStack{
            
        }
        .alert(viewModel.alertMsg, isPresented: $viewModel.isShowAlert) {
            Button("OK", role: .cancel) {
                mainCoordinator.navigateTo(.homePage)
            }
        }
    }
    
}
//
//#Preview {
//    ownerSession()
//}
