//
//  GenericRangeTarget.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI

struct GenericRangeTarget: View {
    let header: String
    let unitHeader: String
    @Binding var minValue: Double?
    @Binding var maxValue: Double?

    @State private var minText: String = ""
    @State private var maxText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(header)
                    .font(.title3)
                    .foregroundColor(Color(red: 0, green: 227/255, blue: 253/255))
                Spacer()
                Text(unitHeader)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.top)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MIN")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    TextField("Any", text: $minText)
                        .font(.title2)
                        .foregroundColor(.white)
                        .keyboardType(.decimalPad)
                        .onChange(of: minText) { _, new in
                            minValue = Double(new)
                        }
                        // Allow FiltersView's toolbar Done to dismiss this field
                        .submitLabel(.done)
                }

                Text("–")
                    .font(.title2)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 4) {
                    Text("MAX")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    TextField("Any", text: $maxText)
                        .font(.title2)
                        .foregroundColor(.white)
                        .keyboardType(.decimalPad)
                        .onChange(of: maxText) { _, new in
                            maxValue = Double(new)
                        }
                        .submitLabel(.done)
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        .padding(.horizontal)
        .padding(.top)
        .onAppear {
            minText = minValue.map { String($0) } ?? ""
            maxText = maxValue.map { String($0) } ?? ""
        }
    }
}
