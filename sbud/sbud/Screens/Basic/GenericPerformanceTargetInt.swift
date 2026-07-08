//
//  GenericPerformanceTargetInt.swift
//  sbud
//
//  Created by ahmed on 19/05/2026.
//

import SwiftUI

struct GenericPerformanceTargetInt: View {
    let targetHeader: String
    let unitHeader: String
    @Binding var targetValue: Int

    private var targetValueString: Binding<String> {
        Binding<String>(
            get: { String(targetValue) },
            set: { targetValue = Int($0) ?? targetValue }
        )
    }

    var body: some View {
        VStack {
            HStack {
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
            HStack {
                TextField("", text: targetValueString)
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                    .keyboardType(.numberPad)
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
    GenericPerformanceTargetInt(
        targetHeader: "Number of Runs",
        unitHeader: "RUNS",
        targetValue: .constant(5))
}

