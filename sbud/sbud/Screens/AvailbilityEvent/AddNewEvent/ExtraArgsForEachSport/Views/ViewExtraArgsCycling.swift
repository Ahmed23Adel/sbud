//
//  ExtraArgsCycling.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI

struct ViewExtraArgsCycling: View {
    @State var args: ExtraArgsHolderCycling
    var body: some View {
        VStack{
            GenericPerformanceTarget(
              targetHeader: "Target Power",
              unitHeader: "W",
              targetValue: $args.proposedPowerInWatt)
            
            GenericPerformanceTarget(
              targetHeader: "Target Cadence",
              unitHeader: "RPM",
              targetValue: $args.proposedCadenceInRPM)
        }
        
        
    }
}

#Preview {
    ViewExtraArgsCycling(args: ExtraArgsHolderCycling())
}
