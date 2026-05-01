//
//  CustumInputView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 30/12/25.
//

import SwiftUI

struct CustomInputView: View {
    @Binding var inputText: String
    let placeholder: String
    let buttonTitle: String
    var action: () -> Void

    var body: some View {
        ZStack(alignment: .trailing) {
            TextField(placeholder, text: $inputText, axis: .vertical)
                .padding(12)
                .padding(.leading, 8)
                .padding(.trailing, 60)
                .background(Color(.systemGroupedBackground))
                .foregroundColor(.white)
                .colorScheme(.dark)
                .clipShape(Capsule())
                .font(.subheadline)

            Button(action: action) {
                Text(buttonTitle)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.mainColor)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .padding(.vertical, 8) 
        .background(Color.darkBackground)
    }
}
