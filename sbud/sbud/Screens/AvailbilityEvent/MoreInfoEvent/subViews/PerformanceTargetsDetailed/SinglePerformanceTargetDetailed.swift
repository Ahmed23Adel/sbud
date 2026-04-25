//
//  SinglePerformanceTargetDetailed.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

struct SinglePerformanceTargetDetailed: View {
    let targetHeader: String
    let unitHeader: String
    let targetValue: String

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
            }
            .padding()

            HStack {
                Text(String(targetValue))
                    .foregroundColor(.white)
                    .font(.title)
                    .padding(.horizontal)
                Spacer()
            }
            HStack {
                Text(unitHeader)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
    }
}

#Preview {
    SinglePerformanceTargetDetailed(targetHeader: "Pace", unitHeader: "Min/Km", targetValue: "5.5")
}
