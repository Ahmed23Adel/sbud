//
//  MultipleDateLocationsHolder.swift
//  sbud
//
//  Created by ahmed on 08/03/2026.
//

import Foundation
import Combine

class MultipleDateLocationsHolder: RandomAccessCollection, ObservableObject{
    @Published var lst: [DateLocations] = []
    var startIndex: Int {lst.startIndex}
    var endIndex: Int {lst.endIndex}
    
    func append(_ newObj: DateLocations){
        lst.append(newObj)
    }
    
    subscript(position: Int) -> DateLocations{
        lst[position]
    }
}
