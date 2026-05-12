//
//  ScannerBrackets.swift
//  sbud
//
//  Created by ahmed on 05/05/2026.
//

import SwiftUI

struct ScannerBrackets: View {
    var body: some View {
        ZStack {
            // top-left
            BracketCorner().offset(x: 14, y: 14)
            // top-right
            BracketCorner().rotationEffect(.degrees(90)).offset(x: -14, y: 14)
            // bottom-right
            BracketCorner().rotationEffect(.degrees(180)).offset(x: -14, y: -14)
            // bottom-left
            BracketCorner().rotationEffect(.degrees(270)).offset(x: 14, y: -14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    ScannerBrackets()
}
