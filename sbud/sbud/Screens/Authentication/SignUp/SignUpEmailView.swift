//
//  SignUpEmailView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 13/12/25.
//

import SwiftUI

struct SignUpEmailView: View {
    @EnvironmentObject var viewModel : SignUpViewModel
    
    var body: some View {
        ZStack{
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{
                
                Text("Add your email")
                    .font(.title)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding(.top)
                TextField("Enter your e-mail: ", text: $viewModel.email)
                    .autocapitalization(.none)
                    .modifier(TextModifierSignUp())
                
                NavigationLink{
                    CreateUsernameView()
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
    }
}

struct SignUpEmailView_Previews : PreviewProvider{
    static var previews: some View{
        SignUpEmailView()
            .environmentObject(SignUpViewModel())
    }
}
