//
//  ICloudFunctionRepository.swift
//  sbud
//
//  Created by ahmed on 25/01/2026.
//

import Foundation


protocol ICloudFunctionRepository {
    associatedtype T
    var funcName: String { get }
    
}
