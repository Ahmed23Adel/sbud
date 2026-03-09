//
//  DateLocationAdder.swift
//  sbud
//
//  Created by ahmed on 07/03/2026.
//

import SwiftUI

struct ViewDateLocationAdder: View {
    @StateObject private var viewModel = ViewModelDateLocationAdder()
    @StateObject var objsDateLocations = MultipleDateLocationsHolder()
    var body: some View {
        ScrollView{
            VStack{
                HStack{
                    
                    Button("Add new date & location", systemImage: "plus"){
                        viewModel.isShowSheetForDateLocations = true
                    }
                    .foregroundColor(Color.mainColor)
                    .padding()
                    .buttonStyle(.borderless)
                    .sheet(isPresented: $viewModel.isShowSheetForDateLocations){
                        ViewSheetForDateLocationsSelection(returnables: objsDateLocations)
                            .presentationDetents([.medium, .large])
                    }
                    
                }
                // plz note that scrollview and list conflicts,
                // List tries to expand to fit its content, but ScrollView gives it infinite height to work with — so List gets confused and collapses to zero height.
                List{
                    ForEach(objsDateLocations.lst, id: \.id ){ obj in
                        VStack(alignment: .leading){
                            
                            Text("From: \(obj.startDate.formatted(date: .abbreviated, time: .shortened))")
                                .foregroundColor(Color.mainColor)
                            Text("To: \(obj.endDate.formatted(date: .abbreviated, time: .shortened))")
                                .foregroundColor(Color.mainColor)
                            Text("Locations: \(obj.locations.count)")
                                .foregroundColor(Color.mainColor)
                        }
                        .listRowBackground(Color.backgroundColor)
                        
                    }
                    .onDelete{ indexOffset in
                        objsDateLocations.lst.remove(atOffsets: indexOffset)
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: CGFloat(objsDateLocations.lst.count) * 160)
                .scrollContentBackground(.hidden)
                .background(Color.backgroundColor.colorMultiply(Color.black.opacity(0.3)))
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                .padding(.horizontal)
                
                
                Button("Submit"){
                    
                }
                .buttonStyle(.borderedProminent)
                .disabled(objsDateLocations.count == 0)
                .foregroundColor(Color.mainColor)
            }
        }
        
    }
}

#Preview {
    ViewDateLocationAdder()
}
