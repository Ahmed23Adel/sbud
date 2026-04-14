//
//  GenericInputView.swift
//  sbud
//
//  Created by ahmed on 14/04/2026.
//

import SwiftUI

struct GenericTextInputView: View {
    let fieldName: String
    let placeholder: String
    let iconString: String
    @Binding var text: String
    var body: some View {
        VStack{
            HStack{
                Text(fieldName)
                    .font(.title2)
                     .foregroundColor(.mainColor)
                     .padding()
                Spacer()
            }
            
            HStack{
                TextField(placeholder, text: $text)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                Spacer()
                Image(systemName: iconString)
                    .foregroundColor(.white)
                    .frame(width: 20)
                    .padding()
            }
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        }
        .padding(.horizontal, 15)
    }
}

#Preview {
    GenericTextInputView(
        fieldName: "Title",
        placeholder: "Ex: Marathon",
        iconString: "text.rectangle", text: .constant(""))
}
