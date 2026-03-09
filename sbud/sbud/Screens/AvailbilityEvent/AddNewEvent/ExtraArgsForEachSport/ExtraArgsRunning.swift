//
//  ExtraArgsRunning.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI

struct ExtraArgsRunning: View {
    @State var proposedDistance = "6.0"
    @State var propsosedPace = "8.30"
    @Binding var returnableArgs: [String: String]
    var body: some View {
        VStack{
            HStack{
                Text("Proposed distance")
                    .foregroundColor(Color.mainColor)
                Spacer()
            }
            .padding([.top, .leading])
            TextField("e.g 6 KM",
                      text: $proposedDistance)
            .foregroundColor(Color.mainColor)
            .padding(.leading)
            .keyboardType(.decimalPad)
            .onChange(of: proposedDistance){ _, newValue in
                returnableArgs["distance"] = newValue
            }
            HStack{
                Text("Proposed pace")
                    .foregroundColor(Color.mainColor)
                    
                Spacer()
            }
            .padding([.top, .leading])
            TextField("e.g 6.50",
                      text: $propsosedPace)
            .foregroundColor(Color.mainColor)
            .keyboardType(.decimalPad)
            .padding([.leading, .bottom])
            .onChange(of: propsosedPace){ _, newValue in
                returnableArgs["pace"] = newValue
            }
        }
        
        
    }
}

#Preview {
    ExtraArgsRunning(returnableArgs: .constant(["pace": "5.3"]))
}
