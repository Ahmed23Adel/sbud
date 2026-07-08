//
//  GenericRangeTargetInt.swift
//  sbud
//
//  Created by ahmed on 19/05/2026.
//

import SwiftUI

struct GenericRangeTargetInt: View {
    let header: String
    let unitHeader: String
    @Binding var minValue: Int?
    @Binding var maxValue: Int?

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
                        .keyboardType(.numberPad)
                        .onChange(of: minText) { _, new in
                            minValue = Int(new)
                        }
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
                        .keyboardType(.numberPad)
                        .onChange(of: maxText) { _, new in
                            maxValue = Int(new)
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
