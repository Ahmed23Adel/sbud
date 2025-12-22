//
//  CreatePasswordView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 14/12/25.
//

import SwiftUI

struct CreatePasswordView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel : SignUpViewModel
    
    var body: some View {
        ZStack{
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{
                Text("Create your password")
                    .font(.title)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding(.top)
                
                Text("At least 6 character in leght")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                //.padding(.horizontal,9)
                
                SecureField("Password", text: $viewModel.password)
                    .autocapitalization(.none)
                    .modifier(TextModifierSignUp())
                    .padding(.top)
                
                NavigationLink{
                    CompleteSignUpView()
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
}

#Preview {
    CreatePasswordView()
}
