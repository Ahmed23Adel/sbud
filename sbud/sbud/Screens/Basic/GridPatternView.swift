//
//  GridPatternView.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import SwiftUI

struct GridPatternView: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 20
            var x: CGFloat = 0
            while x < size.width {
                var p = Path()
                p.move(to: CGPoint(x: x, y: 0))
                p.addLine(to: CGPoint(x: x, y: size.height))
                let randomOpacity = CGFloat.random(in: 0.05...0.2)
                context.stroke(p, with: .color(.white.opacity(randomOpacity)), lineWidth: 0.5)
                x += spacing
            }
            var y: CGFloat = 0
            while y < size.height {
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: size.width, y: y))
                let randomOpacity = CGFloat.random(in: 0.05...0.2)
                context.stroke(p, with: .color(.white.opacity(randomOpacity)), lineWidth: 0.5)
                y += spacing
            }
        }
    }
}


#Preview {
    GridPatternView()
}
