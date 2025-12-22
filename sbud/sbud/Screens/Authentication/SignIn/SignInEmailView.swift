//
//  SignInEmailView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 22/12/25.
//

import SwiftUI

struct SignInEmailView : View {
    @EnvironmentObject var viewModel : SignInViewModel
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                VStack{
                    Spacer()
                    
                    //password fields and username
                    VStack{
                        //email
                        TextField("Enter your e-mail:",text: $viewModel.email)
                            .autocapitalization(.none)
                            .modifier(TextModifierSignUp())
                        SecureField("password:",text: $viewModel.password)
                            .modifier(TextModifierSignUp())
                        
                    }
                    
                    //forgot password
                    Button{
                        print("show forgot password")
                    }label:{
                        Text("Forgot password?")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .padding(.top)
                            .colorMultiply(.black)
                        //.padding(.trailing,28)
                    }
                    
                    Button{
                        Task{try await viewModel.singIn()}
                    }label:{
                        Text("Login")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(width: 360,height: 44)
                            .background(Color.mainColor)
                            .cornerRadius(10)
                        
                    }
                    .padding(.vertical)
                    
                    HStack{
                        Rectangle()
                            .frame(width: (UIScreen.main.bounds.width / 2) - 40, height: 0.5)
                    }
                    Spacer()
                }
            }//Zstack
        }
    }
}

struct SignInEmailView_Previews : PreviewProvider{
    static var previews: some View{
        SignInEmailView()
    }
}
