////
////  RadialLine.swift
////  sbud
////
////  Created by ahmed on 27/12/2025.
////
//
import SwiftUI

struct RadialLine: View {
    let angle: Angle
    let length: CGFloat
    let width: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.mainColor)
            .frame(width: width, height: length)
            .offset(y: -length / 2 - 50)
            .rotationEffect(angle)
    }
}

