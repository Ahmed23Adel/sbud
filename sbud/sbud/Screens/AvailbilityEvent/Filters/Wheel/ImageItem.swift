//
//  ImageItem.swift
//  sbud
//
//  Created by ahmed on 28/12/2025.
//

import SwiftUI

struct ImageItem: View {
    let imageName: String
    let name: String
    
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: imageName)
                .font(.system(size: 50))
                .foregroundColor(.mainColor)
            
            Text(name)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(width: 200)
    }
}


#Preview {
    ImageItem(imageName: "figreu.run", name: "Run")
}
