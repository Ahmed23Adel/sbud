//
//  GenericPerformanceTarget.swift
//  sbud
//
//  Created by ahmed on 14/04/2026.
//

import SwiftUI

struct GenericPerformanceTarget: View {
    let targetHeader: String
    let unitHeader: String
    @Binding var targetValue: Double
    private var targetValueString: Binding<String> {
        Binding<String>(
            get: { String(targetValue) },
            set: {
                targetValue = Double($0) ?? targetValue
            }
        )
    }
    
    var body: some View {
        VStack{
            HStack{
                Text(targetHeader)
                    .font(.title3)
                    .foregroundColor(Color(
                            red: 0.0,
                            green: 227.0/255.0,
                            blue: 253.0/255.0
                        ))
                Spacer()
                Text(unitHeader)
                    .foregroundColor(.gray)
            }
            .padding()
            HStack{
                TextField("", text: targetValueString)
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                    .keyboardType(.decimalPad)
                Spacer()
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
    GenericPerformanceTarget(
        targetHeader: "Distance",
        unitHeader: "KM",
        targetValue: .constant(10.4))
}
