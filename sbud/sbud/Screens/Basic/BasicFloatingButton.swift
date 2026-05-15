//
//  BasicFloatingButton.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI

struct BasicFloatingButton: View {
    var iconName: String
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 54, height: 54)
                .background(Color("palelime"))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 24)
        .padding(.bottom, 25)
    }
}

//#Preview {
//    BasicFloatingButton()
//}
