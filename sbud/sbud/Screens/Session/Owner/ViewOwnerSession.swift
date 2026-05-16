//
//  ownerSession.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI
import SwiftData

struct ViewOwnerSession: View {
    @State private var viewModel: ViewModelOwnerSession
    @EnvironmentObject private var mainCoordinator: MainCoordinator
    @Environment(\.modelContext) private var context
    
    init(eventDetails: EventFullDetails, isSessionCreated: Bool) {
        _viewModel = State(initialValue: ViewModelOwnerSession(eventDetails: eventDetails, isSessionCreated: isSessionCreated))
    }

    var body: some View {
        ZStack{
            Color.darkBackground
                .ignoresSafeArea()
            VStack{
                SessionTimerView(startDate: viewModel.startDateTime)
                    .padding(.top, 100)
                ViewEventSummary(event: viewModel.eventDetails)
                Spacer()
                Button("End session"){
                    
                }
                .buttonStyle(DestructiveButton())
                .padding(.bottom)
            }
        }
        .alert(viewModel.alertMsg, isPresented: $viewModel.isShowAlert) {
            Button("OK", role: .cancel) {
                mainCoordinator.navigateTo(.homePage)
            }
        }
        .onAppear {
            viewModel.setModelContext(context: context)
            if viewModel.isSessionCreated {
                viewModel.readLocalSessionDetails()
            } else {
                viewModel.saveSessoinLocally()
            }
        }
    }
    
}
//
//#Preview {
//    ownerSession()
//}
