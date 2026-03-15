//
//  AddNewEvent.swift
//  sbud
//
//  Created by ahmed on 05/03/2026.
//

import SwiftUI
import Kingfisher
import _PhotosUI_SwiftUI

struct ViewAddNewEvent: View {
    @StateObject private var viewModel = ViewModelAddNewEvent()
    @FocusState private var isKeyboardFocused: Bool

    var body: some View {
        ZStack{
            if viewModel.isLoading{
                LoadingView()
            } else{
                                
                ScrollView{
                    VStack{
                        
                        ViewEventImageSelection(selectedImgURL: $viewModel.selectedImgURL)
                        
                        LabeledContent{
                            TextField("Title", text: $viewModel.orchestrator.title)
                        } label: {
                            Text("Title")
                        }
                        .foregroundColor(.mainColor)
                        .padding()
                        HStack{
                            Text("Sport type")
                                .foregroundColor(.mainColor)
                            Spacer()
                            Picker(
                                "",
                                selection: $viewModel.orchestrator.extraArgsHolder.selectedActivity){
                                    ForEach(ActivityType.allCases, id: \.self){ type in
                                        Text(type.rawValue)
                                    }
                                    .pickerStyle(.menu)
                                }
                                .tint(.mainColor)
                                .padding(.top)
                            Spacer()
                        }
                        .padding()
                        ViewConditionalExtraArgs(argsHolder: viewModel.orchestrator.extraArgsHolder)
                        Toggle(isOn: $viewModel.orchestrator.isEventPublic) {
                            Text("Public event")
                        }
                        .foregroundColor(Color.mainColor)
                        .padding()
                        
                        HStack{
                            Text("Joining condition")
                                .foregroundColor(.mainColor)
                            Spacer()
                            Picker("", selection: $viewModel.orchestrator.joiningCondition){
                                ForEach(JoinCondition.allCases, id: \.self){ cond in
                                    Text(cond.rawValue)
                                }
                            }
                            .tint(Color.mainColor)
                            
                        }
                        .padding()
                        
                        HStack{
                            Text("Max Allowed to join")
                                .foregroundColor(.mainColor)
                            Spacer()
                            TextField("", text: $viewModel.orchestrator.maxAllowedToJoin)
                                .foregroundColor(.mainColor)
                                .focused($isKeyboardFocused)
                                .keyboardType(.numberPad)
                            
                        }
                        .padding()
                        
                        HStack{
                            Text("Notes")
                                .foregroundColor(.mainColor)
                                .font(.title)
                            Spacer()
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        
                        HStack{
                            TextField("Notes", text: $viewModel.orchestrator.notes, axis: .vertical)
                                .foregroundColor(.mainColor)
                                .lineLimit(3...6)
                                .focused($isKeyboardFocused)
                                .padding()
                            Spacer()
                        }
                        .overlay{
                            RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                                .stroke(Color.mainColor, lineWidth: 1)
                        }
                        .padding()
                        ViewDateLocationAdder(objsDateLocations: viewModel.orchestrator.dateLocationsHolder)
                        
                        
                        Button("Submit"){
                            viewModel.submit()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.mainColor)
//                        .disabled(viewModel.orchestrator.dateLocationsHolder.isEmpty)
                        
                        Spacer()
                    } // END Vstack
                    .background(Color.darkBackground)
                    
                } // END scroll view
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom){
                    if isKeyboardFocused{
                        HStack{
                            Spacer()
                            Button("Done"){
                                isKeyboardFocused = false
                            }
                            .foregroundColor(.mainColor)
                            .padding()
                        }
                        .background(Color.darkBackground)
                    }
                }
                // it can't have .ignore safe area here
                // as when there is keyboard, swiftui shrink the safe area, so the sheet will fit in teh new space
                // but then u ignore the safe area
            }
        }
    }
}

#Preview {
    ViewAddNewEvent()
}
