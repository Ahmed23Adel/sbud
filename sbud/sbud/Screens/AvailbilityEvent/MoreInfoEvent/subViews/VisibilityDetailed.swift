//
//  VisibilityDetailed.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

struct VisibilityDetailed: View {
    let isPublic: Bool
    var body: some View {
        HStack{
            if isPublic{
                Text("Public")
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color(red: 0, green: 227/255,blue: 253/255))
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                
                    
            } else{
                Text("Only friends")
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.mainColor)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    
                
            }
        }
    }
}

#Preview {
    VisibilityDetailed(isPublic: true)
}
