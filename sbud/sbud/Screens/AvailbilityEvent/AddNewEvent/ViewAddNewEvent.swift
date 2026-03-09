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
    var body: some View {
        ZStack{
            Color.darkBackground
            VStack{
                ViewEventImageSelection(selectedImgURL: $viewModel.selectedImgURL)
                HStack{
                    Picker(
                        "Sport type",
                        selection: $viewModel.selectedSportType){
                            ForEach(ActivityType.allCases, id: \.self){ type in
                                Text(type.rawValue)
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.top)
                    Spacer()
                }
                
                ViewConditionalExtraArgs(selectedActivity: $viewModel.selectedSportType, extraArgs: $viewModel.extraArgsForSelectedSport)
                    
                ViewDateLocationAdder()
                Spacer()
            }
            
            
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ViewAddNewEvent()
}
