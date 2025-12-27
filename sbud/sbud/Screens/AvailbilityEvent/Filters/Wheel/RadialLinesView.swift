//
//  Wheel.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI

struct RadialLinesView: View {
    let numberOfLines = 36
    let longLineLength: CGFloat = 100
    let shortLineLength: CGFloat = 80
    let lineWidth: CGFloat = 2
        
    var body: some View {
        ZStack {
            ForEach(0..<numberOfLines, id: \.self) { index in
                RadialLine(
                    angle: Angle(degrees: Double(index) * (360.0 / Double(numberOfLines))),
                    length: lineLength(for: index),
                    width: lineWidth
                )
            }
        }
        .frame(width: 250, height: 250)
    }
    
    func lineLength(for index: Int) -> CGFloat {
        let position = index % 3
        return position == 0 ? longLineLength : shortLineLength
    }
    
    
}



#Preview {
    RadialLinesView()
}
