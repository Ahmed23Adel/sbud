//
//  CompleteSignUpView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 15/12/25.
//

import SwiftUI

struct CompleteSignUpView: View {
    @State private var email = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel : SignUpViewModel
    
    var body: some View {
        ZStack{
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{
                Spacer()
                Text("Welcome to SBUD,\(viewModel.username)")
                    .font(.title)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding(.top)
                    .multilineTextAlignment(.center)
                
                Text("Click below to complete the registration")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                //.padding(.horizontal,9)
                
                Button{
                    Task{ try await viewModel.createUser()}
                }label:{
                    Text("Complete Sign Up")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 360,height: 44)
                        .background(Color.mainColor)
                        .cornerRadius(10)
                    
                }
                .padding(.vertical)
                Spacer()
                
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
        }//ZStack
    }
}

#Preview {
    CompleteSignUpView()
}
