//
//  ExtraArgsGym.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI

struct ViewExtraArgsGym: View {
    @State var proposedDayType = GymDayType.push
    @State var args: ExtraArgsHolderGym
    var body: some View {
        VStack{
            HStack{
                Text("Proposed day type")
                    .foregroundColor(Color.mainColor)
                Spacer()
            }
            .padding([.top, .leading])
            Picker("Day type", selection: $proposedDayType){
                ForEach(GymDayType.allCases, id: \.self){ dayType in
                    Text(dayType.rawValue)
                        .foregroundColor(Color.mainColor)
                }
                .pickerStyle(.menu)
            }
            .padding(.leading)
            .onChange(of: proposedDayType){ _, newValue in
                args.proposedDayType = newValue
            }
            
        }
        
    }
}

#Preview {
    ViewExtraArgsGym(args: ExtraArgsHolderGym())
}
