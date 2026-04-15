//
//  GenericMultilineTextInputView.swift
//  sbud
//
//  Created by ahmed on 14/04/2026.
//

import SwiftUI
struct GenericMultilineTextInputView: View {
    let fieldName: String
    let placeholder: String
    let iconString: String
    @Binding var text: String
    
    var body: some View {
        VStack {
            HStack {
                Text(fieldName)
                    .font(.title2)
                    .foregroundColor(.mainColor)
                    .padding()
                Spacer()
            }
            
            HStack(alignment: .top) {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                    
                    TextEditor(text: $text)
                        .font(.body)
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
//                        .frame(minHeight: 100, maxHeight: 200)
                        
                }
                .padding(.vertical, 8)
                .padding(.leading, 12)
                
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
    GenericMultilineTextInputView(
        fieldName: "Description",
        placeholder: "Ex: My marathon training notes...",
        iconString: "text.rectangle",
        text: .constant("")
    )
}
