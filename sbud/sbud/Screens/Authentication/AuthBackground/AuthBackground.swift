//
//  AuthBackground.swift
//  sbud
//
//  Created by ahmed on 31/12/2025.
//

import SwiftUI

struct AuthBackground: View {
    let iconNames = (1...14).map { "background-icon\($0)" }
    let numIconsShown = 25
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                ForEach(0..<numIconsShown, id: \.self) { _ in

                    FloatingIcon(
                        imgName: iconNames.randomElement() ?? "background-icon1",
                        size: CGFloat.random(in: 20...80),
                        positionX: CGFloat.random(in: 0...geometry.size.width),
                        positionY: CGFloat.random(in: 0...geometry.size.height)
                    )
                }

            }
        }

    }
}

#Preview {
    AuthBackground()
}
