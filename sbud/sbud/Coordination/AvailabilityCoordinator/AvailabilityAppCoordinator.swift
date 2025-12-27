//
//  AvailabilityAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI

struct AvailabilityAppCoordinator: View {
    @StateObject private var coordinator = AvailabilityCoordinator()
    
    var body: some View {
        AvailbilityView()
            .environmentObject(coordinator)
            .sheet(item: $coordinator.activeSheet){ sheetType in
                sheetContent(for: sheetType)
            }
    }
    
    @ViewBuilder
    private func sheetContent(for sheetType: AvailabilitySheetType) -> some View{
        switch sheetType{
        case .filter:
            FiltersView()
        }
    }
}

#Preview {
    AvailabilityAppCoordinator()
}
