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
                ViewAddNewEventStep2(eventBuilder: viewModel.newEventBuilder)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Create event")
                    .font(.headline)
                    .foregroundColor(Color.mainColor)
            }
            if #available(iOS 26.0, *) {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentStep == .step1 {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(Color.mainColor)
                        .disabled(viewModel.isLoading)
                        .accessibilityIdentifier("addEvent.cancelButton")
                    } else if viewModel.currentStep == .step2 {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.moveToStep1()
                            }
                        }
                        .foregroundColor(Color.mainColor)
                        .textCase(.uppercase)
                        .disabled(viewModel.isLoading)
                        .accessibilityIdentifier("addEvent.backButton")
                    }
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.currentStep == .step1 {
                        Button("Next") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.moveToStep2()
                            }
                        }
                        .foregroundColor(Color.mainColor)
                        .disabled(viewModel.isLoading)
                        .accessibilityIdentifier("addEvent.nextButton")
                    } else if viewModel.currentStep == .step2 {
                        Button("Done") {
                            viewModel.createEvent()
                        }
                        .foregroundColor(Color.mainColor)
                        .textCase(.uppercase)
                        .disabled(viewModel.isLoading)
                        .accessibilityIdentifier("addEvent.doneButton")
                    }
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.currentStep == .step1 {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(Color.mainColor)
                        .disabled(viewModel.isLoading)
                        .accessibilityIdentifier("addEvent.cancelButton")
                    } else if viewModel.currentStep == .step2 {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.moveToStep1()
                            }
                        }
                        .foregroundColor(Color.mainColor)
                        .textCase(.uppercase)
                        .disabled(viewModel.isLoading)
                        .accessibilityIdentifier("addEvent.backButton")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.currentStep == .step1 {
                        Button("Next") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.moveToStep2()
                            }
                        }
                        .foregroundColor(Color.mainColor)
                        .disabled(viewModel.isLoading)
                        .accessibilityIdentifier("addEvent.nextButton")
                    } else if viewModel.currentStep == .step2 {
                        Button("Done") {
                            viewModel.createEvent()
                        }
                        .foregroundColor(Color.mainColor)
                        .textCase(.uppercase)
                        .disabled(viewModel.isLoading)
                        .accessibilityIdentifier("addEvent.doneButton")
                    }
                }
            }
        }
        .toolbarBackground(Color.darkBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .overlay {
            if viewModel.isLoading {
                MidnightLoadingView(text: "Creating the event")
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
            }
        }
        .onChange(of: viewModel.isDismissed) {
            if viewModel.isDismissed {
                dismiss()
            }
        }
    }
}

#Preview {
    CoordinatorAddNewEvent()
}
