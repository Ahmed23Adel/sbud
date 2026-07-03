//
//  ViewMyEventEdit.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct ViewMyEventEdit: View {
    @State var viewModel: ViewModelMyEventEdit
    @Environment(\.dismiss) private var dismiss

    @State private var currentStep: AddNewEventSteps = .step1

    init(event: EventFullDetails) {
        _viewModel = State(wrappedValue: ViewModelMyEventEdit(event: event))
    }

    var body: some View {
        Group {
            if currentStep == .step1 {
                ViewAddNewEventStep1(eventBuilder: viewModel.eventBuilder)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal:   .move(edge: .leading)))
            } else {
                ViewAddNewEventStep2(eventBuilder: viewModel.eventBuilder)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal:   .move(edge: .trailing)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Edit Event")
                    .font(.headline)
                    .foregroundColor(Color.mainColor)
            }

            ToolbarItem(placement: .topBarLeading) {
                if currentStep == .step1 {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.mainColor)
                        .disabled(viewModel.isLoading)
                } else {
                    Button("Back") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .step1
                        }
                    }
                    .foregroundColor(Color.mainColor)
                    .disabled(viewModel.isLoading)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                if currentStep == .step1 {
                    Button("Next") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .step2
                        }
                    }
                    .foregroundColor(Color.mainColor)
                    .disabled(viewModel.isLoading)
                } else {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button("Save") { viewModel.saveChanges() }
                            .foregroundColor(Color.mainColor)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .onChange(of: viewModel.didSave) { _, saved in
            if saved { dismiss() }
        }
    }
}

