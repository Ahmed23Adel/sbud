//
//  CreateUsernameView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 14/12/25.
//

import SwiftUI

struct CreateUsernameView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel : SignUpViewModel
    
    var body: some View {
        ZStack{
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{
                Text("Create your username")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                TextField("Username", text: $viewModel.username)
                    .autocapitalization(.none)
                    .modifier(TextModifierSignUp())
                
                NavigationLink{
                    CreatePasswordView()
                        .environmentObject(viewModel)
                        .navigationBarBackButtonHidden()
                }label:{
                    Text("Next")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(width: 360,height: 44)
                        .background(Color.mainColor)
                        .cornerRadius(10)
                        
                }
                .padding(.vertical)
            }
            
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
    }
}

struct CreateUsernameView_Previews : PreviewProvider{
    static var previews: some View{
        CreateUsernameView()
            .environmentObject(SignUpViewModel())
    }
}
