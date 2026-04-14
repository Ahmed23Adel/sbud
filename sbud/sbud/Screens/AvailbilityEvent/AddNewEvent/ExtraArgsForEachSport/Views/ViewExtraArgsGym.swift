//
//  ExtraArgsGym.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI

struct ViewExtraArgsGym: View {
    @State var args: ExtraArgsHolderGym
    var body: some View {
        VStack{
            HStack{
                Text("Day Type")
                    .font(.title3)
                    .foregroundColor(Color(
                            red: 0.0,
                            green: 227.0/255.0,
                            blue: 253.0/255.0
                        ))
                Spacer()
                
            }
            .padding()
            Picker("Day type", selection: $args.proposedDayType){
                ForEach(GymDayType.allCases, id: \.self){ dayType in
                    Text(dayType.rawValue)
                        .foregroundColor(Color.mainColor)
                }
                .pickerStyle(.menu)
            }
            .padding()
        }
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .padding(.horizontal)
        .padding(.top)
        
        
    }
}

#Preview {
    ViewExtraArgsGym(args: ExtraArgsHolderGym())
}
