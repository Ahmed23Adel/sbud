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
            }
            
            
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ViewAddNewEvent()
}
