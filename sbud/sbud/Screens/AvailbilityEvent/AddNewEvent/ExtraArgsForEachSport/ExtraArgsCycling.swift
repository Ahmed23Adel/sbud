//
//  ExtraArgsCycling.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI

struct ExtraArgsCycling: View {
    @State var proposedPowerInWatt = "200"
    @State var proposedCadenceInRPM = "80"
    @Binding var returnableArgs: [String: String]
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
                returnableArgs["power"] = newValue
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
                returnableArgs["cadence"] = newValue
            }
        }
        
        
    }
}

#Preview {
    ExtraArgsCycling(returnableArgs: .constant([:]))
}
