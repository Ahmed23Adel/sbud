//
//  GenericMultilineTextView.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI
struct GenericMultilineTextView: View {
    let fieldName: String
    let placeholder: String
    let iconString: String
    var text: String
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                if !text.isEmpty{
                    VStack(spacing: 10){
                        Text(fieldName)
                            .font(.title2)
                            .foregroundColor(Color.mainColor)
                            
                        Text(text)
                            .font(.body)
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                    }
                    .padding(10)
                    Spacer()
                    
                    Image(systemName: iconString)
                        .foregroundColor(.white)
                        .frame(width: 20)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
        }
        .padding(15)
    }
}

#Preview {
    GenericMultilineTextView(
        fieldName: "Description",
        placeholder: "Ex: My marathon training notes...",
        iconString: "text.rectangle",
        text: "notes"
    )
}
