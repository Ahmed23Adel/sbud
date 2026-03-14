//
//  ExtraArgsRunning.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI
import Combine


struct ViewExtraArgsRunning: View {
    @State var proposedDistance = "6.0"
    @State var propsosedPace = "8.30"
    @ObservedObject var args: ExtraArgsHolderRunning
    
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
                args.proposedDistance = newValue
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
                args.propsosedPace = newValue
            }
        }
        
        
    }
}

#Preview {
    ViewExtraArgsRunning(args: ExtraArgsHolderRunning())
}
