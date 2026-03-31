//
//  ExtraArgsCycling.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI

struct ViewExtraArgsCycling: View {
    @State var proposedPowerInWatt = "200"
    @State var proposedCadenceInRPM = "80"
    @State var args: ExtraArgsHolderCycling
    var body: some View {
        VStack{
            HStack{
                Text("Proposed Power")
                    .foregroundColor(Color.mainColor)
                Spacer()
            }
            .padding([.top, .leading])
            TextField("e.g 200 Watt",
                      text: $proposedPowerInWatt)
            .padding(.leading)
            .keyboardType(.decimalPad)
            .foregroundColor(Color.mainColor)
            .onChange(of: proposedPowerInWatt){ _, newValue in
                args.proposedPowerInWatt = newValue
            }
            HStack{
                Text("Proposed Cadence")
                    .foregroundColor(Color.mainColor)
                    
                Spacer()
            }
            .padding([.top, .leading])
            TextField("e.g 80 RPM",
                      text: $proposedCadenceInRPM)
            .keyboardType(.decimalPad)
            .padding([.leading, .bottom])
            .foregroundColor(Color.mainColor)
            .onChange(of: proposedCadenceInRPM){ _, newValue in
                args.proposedCadenceInRPM = newValue
            }
        }
        
        
    }
}

#Preview {
    ViewExtraArgsCycling(args: ExtraArgsHolderCycling())
}
