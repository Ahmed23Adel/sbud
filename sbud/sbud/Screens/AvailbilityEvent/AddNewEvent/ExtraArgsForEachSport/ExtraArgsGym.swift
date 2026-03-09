//
//  ExtraArgsGym.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI

enum GymDayTypes: String, CaseIterable{
    case push = "push"
    case pull = "pull"
    case leg = "leg"
    case arm = "arm"
}

struct ExtraArgsGym: View {
    @State var proposedDayType = GymDayTypes.push
    @Binding var returnableArgs: [String: String]
    var body: some View {
        VStack{
            HStack{
                Text("Proposed day type")
                    .foregroundColor(Color.mainColor)
                Spacer()
            }
            .padding([.top, .leading])
            Picker("Day type", selection: $proposedDayType){
                ForEach(GymDayTypes.allCases, id: \.self){ dayType in
                    Text(dayType.rawValue)
                        .foregroundColor(Color.mainColor)
                }
                .pickerStyle(.menu)
            }
            .padding(.leading)
            .onChange(of: proposedDayType){ _, newValue in
                returnableArgs["dayType"] = newValue.rawValue
            }
            
        }
        
    }
}

#Preview {
    ExtraArgsGym(returnableArgs: .constant([:]))
}
