//
//  StatusRow.swift
//  sbud
//
//  Created by ahmed on 05/02/2026.
//

import SwiftUI
import Lottie

struct StatusRow: View {
    var isPublic: Bool
    var body: some View {
        HStack{
            LottieView(animation: .named(isPublic ? "open" : "friends"))
                .playing()
                .looping()
                .frame(width: 40, height: 40)
                .padding(.leading, 8)
            Text("Status: \(isPublic ? "Public" : "Only friends")")
                .font(.headline)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
            Spacer()
            
        }
        .frame(width: UIConstants.bigCardWidth, height: UIConstants.smallCardHeight)
        .background(
            RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                .fill(Color.backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: UIConstants.cornerRadius)
                .stroke(Color.mainColor, lineWidth: 0.5)
        )
        .popUp()
        .onTapGesture{
            PopUpGenerator.shared.show(msg: isPublic ? "Accessed by all buds": "Accessed Only by friends", type: .information)
        }
        
    }
}

#Preview {
    StatusRow(isPublic: true)
}
