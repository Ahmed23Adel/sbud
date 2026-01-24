//
//  FloatingIconsBackground.swift
//  sbud
//
//  Created by ahmed on 24/01/2026.
//

import SwiftUI


struct FloatingIconsBackground: View {
    let iconNames: Array<String>
    let numIconsShown = 15
    
    init(iconBaseName: IconsBaseName){
        iconNames = (1...10).map { "\(iconBaseName.rawValue)\($0)" }
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                ForEach(0..<numIconsShown, id: \.self) { _ in

                    FloatingIcon(
                        imgName: iconNames.randomElement() ?? "run1",
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
    FloatingIconsBackground(iconBaseName: .running)
}
