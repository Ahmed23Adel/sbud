//
//  AvailabilityAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import Foundation
import Combine

class AvailabilityCoordinator: ObservableObject{
    @Published var activeSheet: AvailabilitySheetType?
    
    func showSheet(_ sheet: AvailabilitySheetType) {
        activeSheet = sheet
    }
    
    func dismissSheet() {
        activeSheet = nil
    }
}
