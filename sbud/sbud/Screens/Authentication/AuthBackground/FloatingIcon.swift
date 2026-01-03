//
//  FloatingIcon.swift
//  sbud
//
//  Created by ahmed on 31/12/2025.
//

import SwiftUI

struct FloatingIcon: View {
    let imgName: String
    let size: CGFloat
    let positionX: CGFloat
    let positionY: CGFloat

    @State private var angle: Double = 0
    let radius: CGFloat
    let duration: Double

    init(imgName: String, size: CGFloat, positionX: CGFloat, positionY: CGFloat) {
        self.imgName = imgName
        self.size = size
        self.positionX = positionX
        self.positionY = positionY
        self.radius = CGFloat.random(in: 5...20)
        self.duration = Double.random(in: 5...20)
    }

    var body: some View {
        Image(imgName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .colorMultiply(.gray)
            .rotationEffect(.degrees(-angle))
            .offset(x: radius)
            .rotationEffect(.degrees(angle))
            .position(x: positionX, y: positionY)
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    angle = 360
                }
            }
            .popUp()
    }
}

#Preview {
    FloatingIcon(imgName: "background-icon1",
                 size: 60,
                 positionX: 40,
                 positionY: 40)
}
