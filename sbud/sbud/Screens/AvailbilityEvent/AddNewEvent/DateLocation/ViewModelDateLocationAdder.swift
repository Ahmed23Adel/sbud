//
//  ViewModelDateLocationAdder.swift
//  sbud
//
//  Created by ahmed on 07/03/2026.
//

import Foundation
import Combine

class ViewModelDateLocationAdder: ObservableObject{
    @Published var dateLoactions: [DateLocations] = []
    @Published var isShowSheetForDateLocations = false
    
    func submitNewEvent(){
        
    }
}
