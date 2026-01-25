//
//  ICloudFunctionRepository.swift
//  sbud
//
//  Created by ahmed on 25/01/2026.
//

import Foundation


protocol ICloudFunctionRepository {
    associatedtype T
    associatedtype Constants: IRepositoryConstants
    var funcName: String { get }
    
}
