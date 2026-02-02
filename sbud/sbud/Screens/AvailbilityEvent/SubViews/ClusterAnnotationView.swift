//
//  ClusterAnnotationView.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import SwiftUI

struct ClusterAnnotationView: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: 35, height: 35)
            
            Text("\(count)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        .popUp()
    }
}


#Preview {
    ClusterAnnotationView(count: 10)
}
