//
//  ViewEventImageSelection.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI
import Kingfisher
import _PhotosUI_SwiftUI

struct ViewEventImageSelection: View {
    @State var viewModel: ViewModelEventImageSelection
    init(eventBuidler: NewEventBuilder){
        _viewModel = State(wrappedValue: ViewModelEventImageSelection(eventBuilder: eventBuidler))
    }
    
    var body: some View {
        ZStack{
            FadingEventImage(coverImgURL: viewModel.eventBuilder.coverImgURL)
            VStack{
                
                PhotosPicker(selection: $viewModel.selectedImgs,
                             maxSelectionCount: 1,
                             matching: .images
                ){
                    if viewModel.isUploading{
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.mainColor)
                    } else{
                        Text("Change")
                    }
                }
                .buttonStyle(.borderless)
                .foregroundColor(Color.mainColor)
                .disabled(viewModel.isUploading)
                .padding()
                .onChange(of: viewModel.selectedImg){
                    Task{
                        await viewModel.uploadSelectedImg()
                    }
                }
            }
        }
    }
}

#Preview {
    ViewEventImageSelection(eventBuidler: NewEventBuilder())
}
