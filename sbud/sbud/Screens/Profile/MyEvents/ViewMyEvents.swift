//
//  MyEvents.swift
//  sbud
//
//  Created by ahmed on 30/04/2026.
//

// There will be activites of type
// proposed
// confirmed
// completed
import SwiftUI

struct ViewMyEvents: View {
    @State var viewModel: ViewModelMyEvents
    
    init(userId: String){
        _viewModel = State(initialValue: ViewModelMyEvents(userId: userId))
    }
    var body: some View {
        VStack{
            
        }
        .alert("Error", isPresented: $viewModel.isShowAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }
    }
}

#Preview {
    ViewMyEvents(userId: "ExbXn3HBUHSrgjwCfYAgKi260k32")
}
