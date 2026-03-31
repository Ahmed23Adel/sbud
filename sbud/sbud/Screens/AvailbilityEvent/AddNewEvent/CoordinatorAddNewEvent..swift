//
//  CoordinatorAddNewEvent..swift
//  sbud
//
//  Created by ahmed on 31/03/2026.
//

import SwiftUI
struct CoordinatorAddNewEvent: View {
    @State var viewModel = ViewModelCoordinatorAddNewEvent()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if viewModel.currentStep == .step1 {
                ViewAddNewEventStep1(eventBuilder: viewModel.newEventBuilder)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .leading)))
            } else if viewModel.currentStep == .step2 {
                ViewAddNewEventStep2()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
    
            ToolbarItem(placement: .principal){
                Text("Create event")
                    .font(.headline)
                    .foregroundColor(Color.mainColor)
            }
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .topBarLeading){
                    if viewModel.currentStep == .step1 {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(Color.mainColor)
                        
                    } else if viewModel.currentStep == .step2 {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.moveToStep1()
                            }
                            
                        }
                        .foregroundColor(Color.mainColor)
                        .textCase(.uppercase)
                    }
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.currentStep == .step1 {
                        Button("Next") {
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.moveToStep2()
                            }
                        }
                        .foregroundColor(Color.mainColor)
                        
                    } else if viewModel.currentStep == .step2{
                        Button("Done") {
                            
                        }
                        .foregroundColor(Color.mainColor)
                        .textCase(.uppercase)
                    }
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .topBarLeading){
                    if viewModel.currentStep == .step1 {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(Color.mainColor)
                        
                    } else if viewModel.currentStep == .step2 {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.moveToStep1()
                            }
                            
                        }
                        .foregroundColor(Color.mainColor)
                        .textCase(.uppercase)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.currentStep == .step1 {
                        Button("Next") {
                            withAnimation(.easeInOut(duration: 0.3)){
                                viewModel.moveToStep2()
                            }
                        }
                        .foregroundColor(Color.mainColor)
                        
                    } else if viewModel.currentStep == .step2{
                        Button("Done") {
                            
                        }
                        .foregroundColor(Color.mainColor)
                        .textCase(.uppercase)
                    }
                }
                
            }
        }
        .toolbarBackground(Color.darkBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    CoordinatorAddNewEvent()
}
