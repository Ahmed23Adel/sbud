//
//  AuthenticationManagerBase.swift
//  sbud
//
//  Created by ahmed on 31/12/2025.
//

import Foundation
import Combine

class AuthenticationManagerLoadable: ObservableObject{
    @Published var isLoading: Bool = true
    
    func finishLoading(){
        isLoading = false
    }
    
    func startLoading(){
        isLoading = true
    }
}



