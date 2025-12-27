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
                .fill(colorForCount)
                .frame(width: sizeForCount, height: sizeForCount)
            
            Text("\(count)")
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(.white)
        }
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var colorForCount: Color {
        switch count {
        case 1...5: return .blue
        case 6...10: return .orange
        case 11...20: return .red
        default: return .purple
        }
    }
    
    private var sizeForCount: CGFloat {
        switch count {
        case 1...5: return 35
        case 6...10: return 45
        case 11...20: return 55
        default: return 65
        }
    }
    
    private var fontSize: CGFloat {
        switch count {
        case 1...5: return 12
        case 6...10: return 14
        case 11...20: return 16
        default: return 18
        }
    }
}


#Preview {
    ClusterAnnotationView(count: 10)
}
