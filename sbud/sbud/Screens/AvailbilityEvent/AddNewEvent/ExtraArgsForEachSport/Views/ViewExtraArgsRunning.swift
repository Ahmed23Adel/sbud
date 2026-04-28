//
//  ExtraArgsRunning.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI
import Combine


struct ViewExtraArgsRunning: View {
    @State var args: ExtraArgsHolderRunning
    
    var body: some View {
        VStack{
            
            TextOptionSelector(
                header: "Cycling Type",
                selected: $args.proposedRunningType
            )
          GenericPerformanceTarget(
            targetHeader: "Target Distance",
            unitHeader: "KM",
            targetValue: $args.proposedDistance)
            
            GenericPerformanceTarget(
              targetHeader: "Target Pace",
              unitHeader: "MIN/KM",
              targetValue: $args.proposedPace)
            
        }
        
        
        
    }
}

#Preview {
    ViewExtraArgsRunning(args: ExtraArgsHolderRunning())
}
