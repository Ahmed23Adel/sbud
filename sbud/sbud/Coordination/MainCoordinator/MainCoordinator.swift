//
//  Coordinator.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//

import Foundation
import Combine

class MainCoordinator: ObservableObject{
    @Published var currentRoute: mainRoute
    
    init(){
        let authManager = AuthenticationManager.shared
        if authManager.checkAuthStatus(){
            currentRoute = .homePage
        } else{
            currentRoute = .signUp
        }
        
    }
    
    func navigateTo(_ route: mainRoute){
        currentRoute = route
    }
    
    func goToSignUp(){
        navigateTo(.signUp)
    }
    
    func goToSignIn(){
        navigateTo(.signIn)
    }
    
    func goToHome(){
        navigateTo(.homePage)
    }
    
    
}
