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
    @Binding var selectedImgURL: String
    @StateObject var viewModel = ViewModelEventImageSelection()
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                KFImage(URL(string: viewModel.eventImgUrl))
                    .placeholder{
                        ProgressView()
                    }
                    .resizable()
                    .frame(height: 130)
                    .scaledToFit()
                    .clipShape(Circle())
                Spacer()
            }
            .padding(.top)
            
            PhotosPicker(selection: $viewModel.selectedImgs,
                         maxSelectionCount: 1,
                         matching: .images
            ){
                if viewModel.isUploading{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.mainColor))
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
            .onChange(of: viewModel.eventImgUrl){
                selectedImgURL = viewModel.eventImgUrl
            }
            Spacer()
                
        }
    }
}

#Preview {
    ViewEventImageSelection(selectedImgURL: .constant("https://firebasestorage.googleapis.com/v0/b/sbud-e5bdd.firebasestorage.app/o/uploads%2Fkd5YqKdsHoeRelMwDgssF9xwE7H3%2Frun8.png?alt=media&token=c99a16df-fce1-4f98-81ea-f5e54f7903fb"))
}
